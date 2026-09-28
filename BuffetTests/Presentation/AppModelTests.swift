import XCTest
@testable import Buffet

@MainActor
final class AppModelTests: XCTestCase {
    private func makeAppModel(_ repository: any ProductRepository) -> AppModel {
        let cart = ManageCartUseCase(repository: InMemoryCartRepository())
        let loadProducts = LoadProductsUseCase(repository: repository)
        return AppModel(catalog: CatalogStore(loadProducts: loadProducts),
                        cart: CartStore(manageCart: cart))
    }

    func testFailureFinishesLoadingAndPreservesExistingItems() async {
        let repository = StubProductRepository()
        let app = makeAppModel(repository)
        await app.loadCatalog()
        app.cart.increaseQuantity(of: "one")
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

    func testCancelLoadingAloneProtectsCatalogAndCartFromOldResults() async {
        let repository = ControlledProductRepository()
        let firstStarted = expectation(description: "First request")
        repository.onRequest = { firstStarted.fulfill() }
        let app = makeAppModel(repository)
        let first = Task { await app.loadCatalog() }
        await fulfillment(of: [firstStarted], timeout: 1)
        app.catalog.cancelLoading()
        let secondStarted = expectation(description: "Second request")
        repository.onRequest = { secondStarted.fulfill() }
        let second = Task { await app.loadCatalog() }
        await fulfillment(of: [secondStarted], timeout: 1)
        repository.continuations[1].resume(returning: [Product(id: "new")])
        await second.value
        repository.continuations[0].resume(returning: [Product(id: "old")])
        await first.value
        XCTAssertEqual(repository.cancelledPages, [0])
        XCTAssertEqual(app.catalog.products.map(\.id), ["new"])
        app.cart.increaseQuantity(of: "new")
        XCTAssertEqual(app.cart.items.map(\.id), ["new"])
        XCTAssertEqual(app.cart.cartItems.first?.quantity, 1)
        XCTAssertFalse(app.catalog.isLoading)
        XCTAssertFalse(app.catalog.isShowingError)
    }

    func testEditsDuringCatalogRefreshKeepQuantitySelectionAndPersistence() async {
        let products = ControlledProductRepository()
        let repository = InMemoryCartRepository(cart: Cart(entries: [
            "one": Cart.Entry(quantity: 2, isSelected: false)
        ]))
        let manageCart = ManageCartUseCase(repository: repository)
        let app = AppModel(catalog: CatalogStore(loadProducts: LoadProductsUseCase(repository: products)),
                           cart: CartStore(manageCart: manageCart))
        let initialStarted = expectation(description: "Initial request")
        products.onRequest = { initialStarted.fulfill() }
        let initial = Task { await app.loadCatalog() }
        await fulfillment(of: [initialStarted], timeout: 1)
        products.continuations[0].resume(returning: [Product(id: "one")])
        await initial.value

        let refreshStarted = expectation(description: "Refresh request")
        products.onRequest = { refreshStarted.fulfill() }
        let refresh = Task { await app.loadCatalog() }
        await fulfillment(of: [refreshStarted], timeout: 1)
        app.cart.increaseQuantity(of: "one")
        app.cart.setSelected(true, productID: "one")
        products.continuations[1].resume(returning: [Product(id: "one", name: "Updated")])
        await refresh.value

        XCTAssertEqual(app.cart.cartItems.first?.quantity, 3)
        XCTAssertEqual(app.cart.cartItems.first?.isSelected, true)
        XCTAssertEqual(app.cart.cartItems.first?.product.name, "Updated")
        XCTAssertEqual(repository.cart.entries["one"], Cart.Entry(quantity: 3, isSelected: true))
        XCTAssertEqual(repository.loadCount, 1)
    }

    func testParentCancellationPropagatesToRequestWithoutPublishingResults() async {
        let products = ControlledProductRepository()
        let started = expectation(description: "Request started")
        products.onRequest = { started.fulfill() }
        let app = makeAppModel(products)
        let task = Task { await app.loadCatalog() }
        await fulfillment(of: [started], timeout: 1)
        task.cancel()
        products.continuations[0].resume(returning: [Product(id: "cancelled")])
        await task.value
        XCTAssertEqual(products.cancelledPages, [0])
        XCTAssertTrue(app.catalog.products.isEmpty)
        XCTAssertTrue(app.cart.items.isEmpty)
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
        app.cart.increaseQuantity(of: "one")
        app.cart.increaseQuantity(of: "one")
        app.cart.setAllSelected(true)
        XCTAssertEqual(app.cart.itemCount, 1)
        XCTAssertEqual(app.cart.totalPrice, Money(decimalString: "0.4"))
        XCTAssertTrue(app.cart.isAllSelected)
        app.cart.removeSelected()
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
        app.cart.increaseQuantity(of: "two")

        app.catalog.searchText = "tea"

        XCTAssertEqual(app.catalog.visibleProducts.map(\.id), ["one"])
        XCTAssertEqual(app.cart.itemCount, 1)
        XCTAssertEqual(app.cart.item(for: Product(id: "two")).quantity, 1)
    }
}
