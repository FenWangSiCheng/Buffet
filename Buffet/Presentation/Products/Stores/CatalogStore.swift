import Foundation
import Observation

/// The catalog feature's state: which products exist, what the customer searched for, and
/// whether a request is in flight. It knows nothing about the cart.
@Observable
@MainActor
final class CatalogStore {
    /// The full catalog, as returned by the backend.
    private(set) var products: [Product] = []
    /// Products matching the current search term, in catalog order.
    private(set) var visibleProducts: [Product] = []
    /// The catalog's current search term; filtering happens as the text changes.
    var searchText = "" {
        didSet { filterProducts() }
    }

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var isShowingError: Bool { errorMessage != nil }

    private let loadProducts: LoadProductsUseCase
    /// Identifies the newest request, so a slower earlier response cannot replace it.
    private var loadID: UUID?
    private var requestTask: Task<[Product], Error>?

    init(loadProducts: LoadProductsUseCase) {
        self.loadProducts = loadProducts
    }

    /// Publishes accepted products and delivers them synchronously to the composing workflow.
    func load(page: Int = 0, onLoaded: ([Product]) -> Void) async {
        guard !Task.isCancelled, !isLoading else { return }
        let id = UUID()
        let request = Task { try await loadProducts.execute(page: page) }
        loadID = id
        requestTask = request
        isLoading = true
        dismissError()
        defer {
            if loadID == id {
                isLoading = false
                loadID = nil
                requestTask = nil
            }
        }
        do {
            let products = try await withTaskCancellationHandler {
                try await request.value
            } onCancel: {
                request.cancel()
            }
            try Task.checkCancellation()
            guard loadID == id else { return }
            setProducts(products)
            onLoaded(products)
        } catch is CancellationError {
            // Leaving the scene is not a user-visible failure.
        } catch {
            guard loadID == id, !Task.isCancelled else { return }
            let repositoryError = (error as? RepositoryError) ?? .unknown
            errorMessage = repositoryError.errorDescription
        }
    }

    func cancelLoading() {
        requestTask?.cancel()
        requestTask = nil
        loadID = nil
        isLoading = false
    }

    func dismissError() {
        errorMessage = nil
    }

    private func setProducts(_ newProducts: [Product]) {
        products = newProducts
        filterProducts()
    }

    private func filterProducts() {
        visibleProducts = products.filter {
            searchText.isEmpty || $0.name.localizedStandardContains(searchText)
        }
    }
}
