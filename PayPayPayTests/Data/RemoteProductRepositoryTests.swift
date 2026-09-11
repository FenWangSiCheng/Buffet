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
    private func makeProvider(data: Data, status: Int = 200,
                              delay: TimeInterval = 0) -> MoyaProvider<ProductEndpoint> {
        MoyaProvider<ProductEndpoint>(endpointClosure: { target in
            Endpoint(url: target.baseURL.absoluteString + target.path,
                     sampleResponseClosure: { @Sendable in .networkResponse(status, data) },
                     method: target.method, task: target.task, httpHeaderFields: nil)
        }, stubClosure: { _ in delay == 0 ? .immediate : .delayed(seconds: delay) })
    }

    @MainActor
    private func makeRepository(data: Data, status: Int = 200, delay: TimeInterval = 0) -> RemoteProductRepository {
        let client = ProductAPIClient(provider: makeProvider(data: data, status: status, delay: delay))
        return RemoteProductRepository(client: client, baseURL: URL(string: "https://example.com/api")!)
    }

    @MainActor
    func testDecodingDoesNotBlockMainThread() async throws {
        let client = ProductAPIClient(provider: makeProvider(data: Data("{}".utf8)))
        let probe: DecodingProbe = try await client.request(
            .products(baseURL: URL(string: "https://example.com")!, page: 0)
        )
        XCTAssertFalse(probe.decodedOnMainThread)
    }

    @MainActor
    func testMapsBackendFieldsAndImageURL() async throws {
        let data = Data(#"[{"id":"one","name":"Tea","original_price":"2.50","price":"2","image":"tea"}]"#.utf8)
        let products = try await makeRepository(data: data).fetchProducts(page: 0)
        XCTAssertEqual(products[0].originalPrice, Money(decimalString: "2.50"))
        XCTAssertEqual(products[0].price, Money(decimalString: "2"))
        XCTAssertEqual(products[0].imageURL?.absoluteString, "https://example.com/api/image/tea")
    }

    @MainActor
    func testRejectsHTTPFailureBeforeDecoding() async {
        do {
            _ = try await makeRepository(data: Data("[]".utf8), status: 503).fetchProducts(page: 0)
            XCTFail("Expected server maintenance")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .serverMaintenance)
        }
    }

    func testMapsConnectivityErrors() {
        XCTAssertEqual(RepositoryError(error: URLError(.notConnectedToInternet)),
                       .notConnectionToInternet)
        XCTAssertEqual(RepositoryError(error: URLError(.timedOut)), .notReachedServer)
    }

    @MainActor
    func testRejectsMalformedPayloadAndEmptyIdentity() async {
        for payload in ["invalid JSON", #"[{"id":"","price":"1"}]"#,
                        #"[{"name":"Missing ID","price":"1"}]"#,
                        #"[{"id":"one","price":"invalid"}]"#,
                        #"[{"id":"one","price":"-1"}]"#] {
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
