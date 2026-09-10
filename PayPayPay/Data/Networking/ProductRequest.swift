import Foundation
import Moya

/// Owns one request and resumes its continuation exactly once on every exit path.
@MainActor
final class ProductRequest<Value: Decodable & Sendable> {
    private var cancellable: Moya.Cancellable?
    private var continuation: CheckedContinuation<Value, Error>?
    private var isCancelled = false

    func start(provider: MoyaProvider<ProductEndpoint>, endpoint: ProductEndpoint,
               continuation: CheckedContinuation<Value, Error>) {
        guard !isCancelled else {
            continuation.resume(throwing: CancellationError())
            return
        }
        self.continuation = continuation
        // Moya defaults to the main queue. Decode on its callback queue and transfer
        // only Sendable results back to the actor that owns request bookkeeping.
        cancellable = provider.request(endpoint, callbackQueue: .global(qos: .userInitiated)) { @Sendable response in
            // Convert framework objects into Sendable values before entering the main actor.
            let result: Result<Value, RepositoryError>
            do {
                result = .success(try response.get().filterSuccessfulStatusCodes().map(Value.self))
            } catch {
                result = .failure(RepositoryError(error: error))
            }
            _Concurrency.Task { @MainActor in
                self.finish(result.mapError { $0 as Error })
            }
        }
    }

    func cancel() {
        isCancelled = true
        finish(.failure(CancellationError()))
    }

    private func finish(_ result: Result<Value, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        cancellable?.cancel()
        cancellable = nil
        continuation.resume(with: result)
    }
}
