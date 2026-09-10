import Combine
import Foundation

/// Shared presentation state for the catalog and cart tabs; dependencies point into Domain.
@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var state = CatalogState()

    private let loadProductsUseCase: LoadProductsUseCase
    private let manageCartUseCase: ManageCartUseCase
    private var loadID: UUID?

    init(loadProducts: LoadProductsUseCase, manageCart: ManageCartUseCase) {
        self.loadProductsUseCase = loadProducts
        self.manageCartUseCase = manageCart
    }

    func increaseQuantity(productID: String) async {
        state.items = await manageCartUseCase.changeQuantity(of: productID, by: 1)
    }

    func decreaseQuantity(productID: String) async {
        state.items = await manageCartUseCase.changeQuantity(of: productID, by: -1)
    }

    func setItemSelected(_ selected: Bool, productID: String) async {
        state.items = await manageCartUseCase.select(selected, productID: productID)
    }

    func setAllSelected(_ selected: Bool) async {
        state.items = await manageCartUseCase.select(selected)
    }

    func removeSelected() async {
        state.items = await manageCartUseCase.removeSelected()
    }

    func load() async {
        guard !Task.isCancelled, !state.isLoading else { return }
        let id = UUID()
        loadID = id
        state.isLoading = true
        dismissError()
        defer {
            if loadID == id {
                state.isLoading = false
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
            state.errorMessage = ((error as? RepositoryError) ?? .unknown).errorDescription()
        }
    }

    func cancelLoading() {
        loadID = nil
        state.isLoading = false
    }

    func dismissError() {
        state.errorMessage = nil
    }
}
