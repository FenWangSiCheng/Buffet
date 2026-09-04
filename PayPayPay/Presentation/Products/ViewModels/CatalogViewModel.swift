import Combine
import Foundation

/// Shared presentation state for the catalog and cart tabs; dependencies point into Domain.
@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var state = CatalogState()

    private let loadProductsUseCase: LoadProductsUseCase
    private let manageCartUseCase: ManageCartUseCase
    private var loadTask: Task<Void, Never>?
    private var loadID: UUID?

    init(loadProducts: LoadProductsUseCase, manageCart: ManageCartUseCase) {
        self.loadProductsUseCase = loadProducts
        self.manageCartUseCase = manageCart
    }

    func dispatch(_ action: CatalogAction) {
        switch action {
        case .loadProducts:
            guard loadTask == nil, !state.isLoading else { return }
            loadTask = Task { [weak self] in await self?.loadProducts() }
        case .increaseQuantity(let id):
            state.items = manageCartUseCase.changeQuantity(of: id, by: 1, in: state.items)
        case .decreaseQuantity(let id):
            state.items = manageCartUseCase.changeQuantity(of: id, by: -1, in: state.items)
        case .selectItem(let id):
            state.items = manageCartUseCase.select(true, productID: id, in: state.items)
        case .deselectItem(let id):
            state.items = manageCartUseCase.select(false, productID: id, in: state.items)
        case .selectAll:
            state.items = manageCartUseCase.select(true, in: state.items)
        case .deselectAll:
            state.items = manageCartUseCase.select(false, in: state.items)
        case .removeSelected:
            state.items = manageCartUseCase.removeSelected(from: state.items)
        }
    }

    func loadProducts() async {
        guard !Task.isCancelled, !state.isLoading else { return }
        let id = UUID()
        loadID = id
        state.isLoading = true
        dismissError()
        defer {
            if loadID == id {
                state.isLoading = false
                loadTask = nil
                loadID = nil
            }
        }
        do {
            let items = try await loadProductsUseCase.execute()
            guard loadID == id else { return }
            state.items = items
        } catch is CancellationError {
            // Leaving the scene is not a user-visible failure.
        } catch {
            guard loadID == id else { return }
            state.error = (error as? RepositoryError) ?? .unknown
            state.isShowingError = true
        }
    }

    func cancelLoading() {
        loadID = nil
        loadTask?.cancel()
        loadTask = nil
        state.isLoading = false
    }

    func dismissError() {
        state.error = nil
        state.isShowingError = false
    }
}
