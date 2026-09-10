import Foundation
import Moya

@MainActor
final class ProductAPIClient {
    private let provider: MoyaProvider<ProductEndpoint>

    init(provider: MoyaProvider<ProductEndpoint>) { self.provider = provider }

    func request<Value: Decodable & Sendable>(_ endpoint: ProductEndpoint) async throws -> Value {
        let request = ProductRequest<Value>()
        return try await withTaskCancellationHandler {
            try _Concurrency.Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                request.start(provider: provider, endpoint: endpoint, continuation: continuation)
            }
        } onCancel: {
            _Concurrency.Task { @MainActor in request.cancel() }
        }
    }
}
