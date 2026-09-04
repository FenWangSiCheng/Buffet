import Foundation
@testable import PayPayPay

@MainActor
final class InMemoryCartRepository: CartRepository {
    var counts: [String: Int] = [:]
    var selections: [String: Bool] = [:]
    func count(for productID: String) -> Int { counts[productID, default: 0] }
    func setCount(_ count: Int, for productID: String) { counts[productID] = count }
    func isSelected(for productID: String) -> Bool { selections[productID, default: false] }
    func setSelected(_ selected: Bool, for productID: String) { selections[productID] = selected }
}

@MainActor
final class StubProductRepository: ProductRepository {
    var result: Result<[Product], Error> = .success([Product(id: "one", price: "0.2")])
    func fetchProducts(page: Int) async throws -> [Product] { try result.get() }
}

@MainActor
final class ControlledProductRepository: ProductRepository {
    var continuations: [CheckedContinuation<[Product], Error>] = []
    var onRequest: (() -> Void)?
    private(set) var pages: [Int] = []

    func fetchProducts(page: Int) async throws -> [Product] {
        pages.append(page)
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
            onRequest?()
        }
    }
}
