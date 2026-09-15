import XCTest
@testable import Buffet

@MainActor
final class AppModelTests: XCTestCase {
    private func makeAppModel(_ repository: any ProductRepository) -> AppModel {
        let cart = ManageCartUseCase(repository: InMemoryCartRepository())
        return AppModel(catalog: CatalogStore(loadProducts: LoadProductsUseCase(repository: repository,
                                                                                cart: cart)),
                        cart: CartStore(manageCart: cart))
    }

    func testFailureFinishesLoadingAndPreservesExistingItems() async {
        let repository = StubProductRepository()
        let app = makeAppModel(repository)
        await app.loadCatalog()
        await app.cart.increaseQuantity(of: "one")
        repository.result = .failure(RepositoryError.unreachable)
        await app.loadCatalog()
        XCTAssertFalse(app.catalog.isLoading)
        XCTAssertTrue(app.catalog.isShowingError)
        XCTAssertEqual(app.catalog.errorMessage, RepositoryError.unreachable.errorDescription)
        XCTAssertEqual(app.catalog.products.map(\.id), ["one"])
        XCTAssertEqual(app.cart.item(for: Product(id: "one")).quantity, 1)
        repository.result = .success([Product(id: "one")])
        await app.loadCatalog()
        XCTAssertNil(app.catalog.errorMessage)
        XCTAssertFalse(app.catalog.isShowingError)
        XCTAssertEqual(app.cart.item(for: Product(id: "one")).quantity, 1)
    }

    func testLoadingDeduplicatesConcurrentRequests() async {
        let repository = ControlledProductRepository()
        let started = expectation(description: "Request started")
        repository.onRequest = { started.fulfill() }
        let app = makeAppModel(repository)
        let task = Task { await app.loadCatalog() }
        await fulfillment(of: [started], timeout: 1)
        XCTAssertTrue(app.catalog.isLoading)
        await app.loadCatalog()
        XCTAssertEqual(repository.pages.count, 1)
        repository.continuations[0].resume(returning: [])
        await task.value
        XCTAssertFalse(app.catalog.isLoading)
    }

    func testCancelledRequestCannotReplaceNewerResults() async {
        let repository = ControlledProductRepository()
        let firstStarted = expectation(description: "First request")
        repository.onRequest = { firstStarted.fulfill() }
        let app = makeAppModel(repository)
        let first = Task { await app.loadCatalog() }
        await fulfillment(of: [firstStarted], timeout: 1)
        app.catalog.cancelLoading()
        first.cancel()
        let secondStarted = expectation(description: "Second request")
        repository.onRequest = { secondStarted.fulfill() }
        let second = Task { await app.loadCatalog() }
        await fulfillment(of: [secondStarted], timeout: 1)
        repository.continuations[1].resume(returning: [Product(id: "new")])
        await second.value
        repository.continuations[0].resume(returning: [Product(id: "old")])
        await first.value
        XCTAssertEqual(app.catalog.products.map(\.id), ["new"])
        XCTAssertFalse(app.catalog.isLoading)
        XCTAssertFalse(app.catalog.isShowingError)
    }

    func testImmediateCancelThenReloadStartsFreshTask() async {
        let repository = ControlledProductRepository()
        let started = expectation(description: "Fresh request")
        repository.onRequest = { started.fulfill() }
        let app = makeAppModel(repository)
        let cancelled = Task { await app.loadCatalog() }
        cancelled.cancel()
        await cancelled.value
        let fresh = Task { await app.loadCatalog() }
        await fulfillment(of: [started], timeout: 1)
        XCTAssertEqual(repository.pages.count, 1)
        repository.continuations[0].resume(returning: [Product(id: "fresh")])
        await fresh.value
        XCTAssertEqual(app.catalog.products.map(\.id), ["fresh"])
    }

    func testCancellationDoesNotPresentError() async {
        let repository = StubProductRepository()
        repository.result = .failure(CancellationError())
        let app = makeAppModel(repository)
        await app.loadCatalog()
        XCTAssertFalse(app.catalog.isLoading)
        XCTAssertFalse(app.catalog.isShowingError)
        XCTAssertNil(app.catalog.errorMessage)
    }

    func testCartMethodsDriveBadgeTotalAndEmptyState() async {
        let app = makeAppModel(StubProductRepository())
        XCTAssertFalse(app.cart.isAllSelected)
        XCTAssertEqual(app.cart.totalPrice, .zero)
        await app.loadCatalog()
        await app.cart.increaseQuantity(of: "one")
        await app.cart.increaseQuantity(of: "one")
        await app.cart.setAllSelected(true)
        XCTAssertEqual(app.cart.itemCount, 1)
        XCTAssertEqual(app.cart.totalPrice, Money(decimalString: "0.4"))
        XCTAssertTrue(app.cart.isAllSelected)
        await app.cart.removeSelected()
        XCTAssertEqual(app.cart.itemCount, 0)
        XCTAssertFalse(app.cart.hasSelection)
        XCTAssertFalse(app.cart.isAllSelected)
    }

    /// Searching is a catalog concern: it must not disturb what the cart holds.
    func testSearchFiltersWithoutTouchingCart() async {
        let repository = StubProductRepository()
        repository.result = .success([Product(id: "one", name: "Tea"),
                                      Product(id: "two", name: "Coffee")])
        let app = makeAppModel(repository)
        await app.loadCatalog()
        await app.cart.increaseQuantity(of: "two")

        app.catalog.searchText = "tea"

        XCTAssertEqual(app.catalog.visibleProducts.map(\.id), ["one"])
        XCTAssertEqual(app.cart.itemCount, 1)
        XCTAssertEqual(app.cart.item(for: Product(id: "two")).quantity, 1)
    }
}
