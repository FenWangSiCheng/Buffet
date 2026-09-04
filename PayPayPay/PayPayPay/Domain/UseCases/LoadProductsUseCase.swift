import Foundation

@MainActor
struct LoadProductsUseCase {
    let repository: ProductRepository
    let cart: ManageCartUseCase

    func execute(page: Int = 0) async throws -> [CartItem] {
        let products = try await repository.fetchProducts(page: page)
        try Task.checkCancellation()
        // Read the cart after the request, so edits made during loading are retained.
        return cart.restore(products: products)
    }
}
