protocol ProductRepository: Sendable {
    func fetchProducts(page: Int) async throws -> [Product]
}
