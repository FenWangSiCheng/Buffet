import Foundation

actor RemoteProductRepository: ProductRepository {
    private let client: ProductAPIClient
    private let baseURL: URL

    init(client: ProductAPIClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    func fetchProducts(page: Int) async throws -> [Product] {
        do {
            let response: [ProductDTO] = try await client.request(.products(baseURL: baseURL, page: page))
            let imageBaseURL = baseURL.appendingPathComponent("image")
            return try response.map { try $0.toDomain(imageBaseURL: imageBaseURL) }
        } catch is CancellationError {
            // Cancellation has to stay distinguishable from a failure, so callers can ignore stale results.
            throw CancellationError()
        } catch {
            throw RepositoryError(error: error)
        }
    }
}
