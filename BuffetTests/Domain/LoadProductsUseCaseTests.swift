import XCTest
@testable import Buffet

final class LoadProductsUseCaseTests: XCTestCase {
    @MainActor
    func testReturnsProductsAndForwardsPage() async throws {
        let products = ControlledProductRepository()
        let started = expectation(description: "Request started")
        products.onRequest = { started.fulfill() }
        let useCase = LoadProductsUseCase(repository: products)
        let task = Task { try await useCase.execute(page: 2) }
        await fulfillment(of: [started], timeout: 1)
        products.continuations[0].resume(returning: [Product(id: "one")])
        let result = try await task.value
        XCTAssertEqual(products.pages, [2])
        XCTAssertEqual(result.map(\.id), ["one"])
    }

    @MainActor
    func testCancellationRejectsResultFromUncooperativeRepository() async {
        let products = ControlledProductRepository()
        let started = expectation(description: "Request started")
        products.onRequest = { started.fulfill() }
        let useCase = LoadProductsUseCase(repository: products)
        let task = Task { try await useCase.execute() }
        await fulfillment(of: [started], timeout: 1)
        task.cancel()
        products.continuations[0].resume(returning: [Product(id: "old")])
        do {
            _ = try await task.value
            XCTFail("A cancelled request must not return products")
        } catch is CancellationError {
            // Expected even when the repository does not handle cancellation.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
