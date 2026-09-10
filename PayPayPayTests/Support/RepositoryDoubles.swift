import Foundation
@testable import PayPayPay

@MainActor
final class InMemoryCartRepository: CartRepository {
    private(set) var cart: Cart

    init(cart: Cart = Cart()) {
        self.cart = cart
    }

    func load(for productIDs: [String]) -> Cart {
        cart
    }

    func save(_ cart: Cart) {
        self.cart = cart
    }
}

@MainActor
final class StubProductRepository: ProductRepository {
    var result: Result<[Product], Error> = .success([
        Product(id: "one", price: Money(decimalString: "0.2")!)
    ])
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
