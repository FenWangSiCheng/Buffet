import Foundation

struct LoadProductsUseCase: Sendable {
    let repository: any ProductRepository
    let cart: ManageCartUseCase

    func execute(page: Int = 0) async throws -> [CartItem] {
        let products = try await repository.fetchProducts(page: page)
        try Task.checkCancellation()
        // Read the cart after the request, so edits made during loading are retained.
        return await cart.restore(products: products)
    }
}
