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

    init(loadProducts: LoadProductsUseCase) {
        self.loadProducts = loadProducts
    }

    /// Loads a page of the catalog.
    ///
    /// Returns the cart-annotated snapshot so the caller can hand it to `CartStore`; the catalog
    /// itself only keeps the products, which is why the cart lives in its own store.
    func load(page: Int = 0) async -> [CartItem]? {
        guard !Task.isCancelled, !isLoading else { return nil }
        let id = UUID()
        loadID = id
        isLoading = true
        dismissError()
        defer {
            if loadID == id {
                isLoading = false
                loadID = nil
            }
        }
        do {
            let items = try await loadProducts.execute(page: page)
            guard loadID == id else { return nil }
            setProducts(items.map(\.product))
            return items
        } catch is CancellationError {
            // Leaving the scene is not a user-visible failure.
            return nil
        } catch {
            guard loadID == id else { return nil }
            let repositoryError = (error as? RepositoryError) ?? .unknown
            errorMessage = repositoryError.errorDescription
            return nil
        }
    }

    func cancelLoading() {
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
