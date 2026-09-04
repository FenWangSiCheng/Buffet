import Combine
import XCTest
@testable import PayPayPay

final class CatalogViewModelTests: XCTestCase {
    @MainActor
    private func makeViewModel(_ repository: ProductRepository) -> CatalogViewModel {
        let cart = ManageCartUseCase(repository: InMemoryCartRepository())
        return CatalogViewModel(loadProducts: LoadProductsUseCase(repository: repository, cart: cart),
                                manageCart: cart)
    }

    @MainActor
    func testFailureFinishesLoadingAndPreservesExistingItems() async {
        let repository = StubProductRepository()
        let viewModel = makeViewModel(repository)
        await viewModel.loadProducts()
        viewModel.dispatch(.increaseQuantity(productID: "one"))
        repository.result = .failure(RepositoryError.notReachedServer)
        await viewModel.loadProducts()
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertTrue(viewModel.state.isShowingError)
        XCTAssertEqual(viewModel.state.error, .notReachedServer)
        XCTAssertEqual(viewModel.state.items[0].quantity, 1)
        repository.result = .success([Product(id: "one")])
        await viewModel.loadProducts()
        XCTAssertNil(viewModel.state.error)
        XCTAssertFalse(viewModel.state.isShowingError)
        XCTAssertEqual(viewModel.state.items[0].quantity, 1)
    }

    @MainActor
    func testLoadingDeduplicatesConcurrentRequests() async {
        let repository = ControlledProductRepository()
        let started = expectation(description: "Request started")
        repository.onRequest = { started.fulfill() }
        let viewModel = makeViewModel(repository)
        let task = Task { await viewModel.loadProducts() }
        await fulfillment(of: [started], timeout: 1)
        XCTAssertTrue(viewModel.state.isLoading)
        await viewModel.loadProducts()
        XCTAssertEqual(repository.pages.count, 1)
        repository.continuations[0].resume(returning: [])
        await task.value
        XCTAssertFalse(viewModel.state.isLoading)
    }

    @MainActor
    func testCancelledRequestCannotReplaceNewerResults() async {
        let repository = ControlledProductRepository()
        let firstStarted = expectation(description: "First request")
        repository.onRequest = { firstStarted.fulfill() }
        let viewModel = makeViewModel(repository)
        let first = Task { await viewModel.loadProducts() }
        await fulfillment(of: [firstStarted], timeout: 1)
        viewModel.cancelLoading()
        let secondStarted = expectation(description: "Second request")
        repository.onRequest = { secondStarted.fulfill() }
        let second = Task { await viewModel.loadProducts() }
        await fulfillment(of: [secondStarted], timeout: 1)
        repository.continuations[1].resume(returning: [Product(id: "new")])
        await second.value
        repository.continuations[0].resume(returning: [Product(id: "old")])
        await first.value
        XCTAssertEqual(viewModel.state.items.map(\.id), ["new"])
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertFalse(viewModel.state.isShowingError)
    }

    @MainActor
    func testImmediateCancelThenReloadStartsFreshTask() async {
        let repository = ControlledProductRepository()
        let started = expectation(description: "Fresh request")
        repository.onRequest = { started.fulfill() }
        let loaded = expectation(description: "Fresh result")
        let viewModel = makeViewModel(repository)
        let subscription = viewModel.$state.filter { !$0.items.isEmpty }.prefix(1).sink { _ in loaded.fulfill() }
        viewModel.dispatch(.loadProducts)
        viewModel.cancelLoading()
        viewModel.dispatch(.loadProducts)
        await fulfillment(of: [started], timeout: 1)
        XCTAssertEqual(repository.pages.count, 1)
        repository.continuations[0].resume(returning: [Product(id: "fresh")])
        await fulfillment(of: [loaded], timeout: 1)
        withExtendedLifetime(subscription) {}
    }

    @MainActor
    func testCancellationDoesNotPresentError() async {
        let repository = StubProductRepository()
        repository.result = .failure(CancellationError())
        let viewModel = makeViewModel(repository)
        await viewModel.loadProducts()
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertFalse(viewModel.state.isShowingError)
        XCTAssertNil(viewModel.state.error)
    }

    @MainActor
    func testCartActionsDriveBadgeTotalAndEmptyState() async {
        let viewModel = makeViewModel(StubProductRepository())
        XCTAssertFalse(viewModel.state.isAllSelected)
        XCTAssertEqual(viewModel.state.totalPrice, 0)
        await viewModel.loadProducts()
        viewModel.dispatch(.increaseQuantity(productID: "one"))
        viewModel.dispatch(.increaseQuantity(productID: "one"))
        viewModel.dispatch(.selectAll)
        XCTAssertEqual(viewModel.state.cartItemCount, 1)
        XCTAssertEqual(viewModel.state.totalPrice, 0.4, accuracy: 0.0001)
        XCTAssertTrue(viewModel.state.isAllSelected)
        viewModel.dispatch(.removeSelected)
        XCTAssertEqual(viewModel.state.cartItemCount, 0)
        XCTAssertFalse(viewModel.state.hasSelection)
        XCTAssertFalse(viewModel.state.isAllSelected)
    }
}
