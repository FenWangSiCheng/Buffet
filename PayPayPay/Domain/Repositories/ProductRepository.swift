@MainActor
protocol ProductRepository {
    func fetchProducts(page: Int) async throws -> [Product]
}
