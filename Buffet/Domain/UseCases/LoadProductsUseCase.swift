import Foundation

struct LoadProductsUseCase: Sendable {
    let repository: any ProductRepository

    func execute(page: Int = 0) async throws -> [Product] {
        let products = try await repository.fetchProducts(page: page)
        try Task.checkCancellation()
        return products
    }
}
