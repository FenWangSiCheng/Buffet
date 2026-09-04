import Foundation

@MainActor
final class RemoteProductRepository: ProductRepository {
    private let client: ProductAPIClient
    private let baseURL: URL

    init(client: ProductAPIClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    func fetchProducts(page: Int) async throws -> [Product] {
        do {
            let response: [ProductDTO] = try await client.request(.products(baseURL: baseURL, page: page))
            return try response.map { try $0.toDomain(imageBaseURL: baseURL.appendingPathComponent("image")) }
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RepositoryError(error: error)
        }
    }
}
