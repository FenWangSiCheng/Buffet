import XCTest
@testable import PayPayPay

final class LoadProductsUseCaseTests: XCTestCase {
    @MainActor
    func testRestoresLatestCartAfterRequestCompletesAndForwardsPage() async throws {
        let products = ControlledProductRepository()
        let cart = InMemoryCartRepository()
        let started = expectation(description: "Request started")
        products.onRequest = { started.fulfill() }
        let manageCart = ManageCartUseCase(repository: cart)
        let useCase = LoadProductsUseCase(repository: products, cart: manageCart)
        let task = Task { try await useCase.execute(page: 2) }
        await fulfillment(of: [started], timeout: 1)
        cart.save(Cart(entries: ["one": Cart.Entry(quantity: 3, isSelected: true)]))
        products.continuations[0].resume(returning: [Product(id: "one")])
        let items = try await task.value
        XCTAssertEqual(products.pages, [2])
        XCTAssertEqual(items[0].quantity, 3)
        XCTAssertTrue(items[0].isSelected)
    }
}
