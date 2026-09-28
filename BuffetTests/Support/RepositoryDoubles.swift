import Foundation
@testable import Buffet

@MainActor
final class InMemoryCartRepository: CartRepository {
    private(set) var cart: Cart
    private(set) var loadCount = 0

    init(cart: Cart = Cart()) {
        self.cart = cart
    }

    func load(for productIDs: [String]) -> Cart {
        loadCount += 1
        return cart
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
    private(set) var cancelledPages: [Int] = []

    func fetchProducts(page: Int) async throws -> [Product] {
        pages.append(page)
        let products: [Product] = try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
            onRequest?()
        }
        if Task.isCancelled { cancelledPages.append(page) }
        return products
    }
}
