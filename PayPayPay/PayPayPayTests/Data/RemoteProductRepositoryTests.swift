import Moya
import XCTest
@testable import PayPayPay

final class RemoteProductRepositoryTests: XCTestCase {
    private struct DecodingProbe: Decodable, Sendable {
        let decodedOnMainThread: Bool

        init(from decoder: Decoder) throws {
            decodedOnMainThread = Thread.isMainThread
        }
    }

    @MainActor
    func testDecodingDoesNotBlockMainThread() async throws {
        let provider = MoyaProvider<ProductEndpoint>(endpointClosure: { target in
            Endpoint(url: target.baseURL.absoluteString + target.path,
                     sampleResponseClosure: { @Sendable in .networkResponse(200, Data("{}".utf8)) },
                     method: target.method, task: target.task, httpHeaderFields: nil)
        }, stubClosure: MoyaProvider.immediatelyStub)
        let client = ProductAPIClient(provider: provider)
        let probe: DecodingProbe = try await client.request(.products(baseURL: URL(string: "https://example.com")!, page: 0))
        XCTAssertFalse(probe.decodedOnMainThread)
    }

    @MainActor
    private func makeRepository(status: Int = 200, data: Data, delay: TimeInterval = 0) -> RemoteProductRepository {
        let provider = MoyaProvider<ProductEndpoint>(endpointClosure: { target in
            Endpoint(url: target.baseURL.absoluteString + target.path,
                     sampleResponseClosure: { @Sendable in .networkResponse(status, data) },
                     method: target.method, task: target.task, httpHeaderFields: nil)
        }, stubClosure: { _ in delay == 0 ? .immediate : .delayed(seconds: delay) })
        return RemoteProductRepository(client: ProductAPIClient(provider: provider),
                                       baseURL: URL(string: "https://example.com/api")!)
    }

    @MainActor
    func testMapsBackendFieldsAndImageURL() async throws {
        let data = Data(#"[{"id":"one","name":"Tea","original_price":"2.50","price":"2","image":"tea"}]"#.utf8)
        let products = try await makeRepository(data: data).fetchProducts(page: 0)
        XCTAssertEqual(products[0].originalPrice, "2.50")
        XCTAssertEqual(products[0].imageURL?.absoluteString, "https://example.com/api/image/tea")
    }

    @MainActor
    func testRejectsHTTPFailureBeforeDecoding() async {
        do {
            _ = try await makeRepository(status: 503, data: Data("[]".utf8)).fetchProducts(page: 0)
            XCTFail("Expected server maintenance")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .serverMaintenance)
        }
    }

    @MainActor
    func testRejectsMalformedPayloadAndEmptyIdentity() async {
        for payload in ["invalid JSON", #"[{"id":""}]"#, #"[{"name":"Missing ID"}]"#] {
            do {
                _ = try await makeRepository(data: Data(payload.utf8)).fetchProducts(page: 0)
                XCTFail("Expected invalid data")
            } catch {
                XCTAssertEqual(error as? RepositoryError, .incorrectDataReturned)
            }
        }
    }

    @MainActor
    func testInFlightCancellationFinishesWithoutWaitingForResponse() async {
        let repository = makeRepository(data: Data("[]".utf8), delay: 30)
        let task = _Concurrency.Task { try await repository.fetchProducts(page: 0) }
        await _Concurrency.Task.yield()
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }
}
