import XCTest
@testable import PayPayPay

final class CatalogViewModelTests: XCTestCase {
    @MainActor
    private func makeViewModel(_ repository: any ProductRepository) -> CatalogViewModel {
        let cart = ManageCartUseCase(repository: InMemoryCartRepository())
        return CatalogViewModel(loadProducts: LoadProductsUseCase(repository: repository, cart: cart),
                                manageCart: cart)
    }

    @MainActor
    func testFailureFinishesLoadingAndPreservesExistingItems() async {
        let repository = StubProductRepository()
        let viewModel = makeViewModel(repository)
        await viewModel.load()
        await viewModel.increaseQuantity(productID: "one")
        repository.result = .failure(RepositoryError.notReachedServer)
        await viewModel.load()
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertTrue(viewModel.state.isShowingError)
        XCTAssertEqual(viewModel.state.errorMessage, RepositoryError.notReachedServer.errorDescription())
        XCTAssertEqual(viewModel.state.items[0].quantity, 1)
        repository.result = .success([Product(id: "one")])
        await viewModel.load()
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertFalse(viewModel.state.isShowingError)
        XCTAssertEqual(viewModel.state.items[0].quantity, 1)
    }

    @MainActor
    func testLoadingDeduplicatesConcurrentRequests() async {
        let repository = ControlledProductRepository()
        let started = expectation(description: "Request started")
        repository.onRequest = { started.fulfill() }
        let viewModel = makeViewModel(repository)
        let task = Task { await viewModel.load() }
        await fulfillment(of: [started], timeout: 1)
        XCTAssertTrue(viewModel.state.isLoading)
        await viewModel.load()
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
        let first = Task { await viewModel.load() }
        await fulfillment(of: [firstStarted], timeout: 1)
        viewModel.cancelLoading()
        first.cancel()
        let secondStarted = expectation(description: "Second request")
        repository.onRequest = { secondStarted.fulfill() }
        let second = Task { await viewModel.load() }
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
        let viewModel = makeViewModel(repository)
        let cancelled = Task { await viewModel.load() }
        cancelled.cancel()
        await cancelled.value
        let fresh = Task { await viewModel.load() }
        await fulfillment(of: [started], timeout: 1)
        XCTAssertEqual(repository.pages.count, 1)
        repository.continuations[0].resume(returning: [Product(id: "fresh")])
        await fresh.value
        XCTAssertEqual(viewModel.state.items.map(\.id), ["fresh"])
    }

    @MainActor
    func testCancellationDoesNotPresentError() async {
        let repository = StubProductRepository()
        repository.result = .failure(CancellationError())
        let viewModel = makeViewModel(repository)
        await viewModel.load()
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertFalse(viewModel.state.isShowingError)
        XCTAssertNil(viewModel.state.errorMessage)
    }

    @MainActor
    func testCartMethodsDriveBadgeTotalAndEmptyState() async {
        let viewModel = makeViewModel(StubProductRepository())
        XCTAssertFalse(viewModel.state.isAllSelected)
        XCTAssertEqual(viewModel.state.totalPrice, .zero)
        await viewModel.load()
        await viewModel.increaseQuantity(productID: "one")
        await viewModel.increaseQuantity(productID: "one")
        await viewModel.setAllSelected(true)
        XCTAssertEqual(viewModel.state.cartItemCount, 1)
        XCTAssertEqual(viewModel.state.totalPrice, Money(decimalString: "0.4"))
        XCTAssertTrue(viewModel.state.isAllSelected)
        await viewModel.removeSelected()
        XCTAssertEqual(viewModel.state.cartItemCount, 0)
        XCTAssertFalse(viewModel.state.hasSelection)
        XCTAssertFalse(viewModel.state.isAllSelected)
    }
}
