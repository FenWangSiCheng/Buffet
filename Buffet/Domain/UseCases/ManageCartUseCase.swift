/// Owns the session cart; local persistence and mutations have no suspension points.
@MainActor
final class ManageCartUseCase {
    private let repository: any CartRepository
    private var products: [Product] = []
    private var cart = Cart()
    private var hasRestored = false

    init(repository: any CartRepository) {
        self.repository = repository
    }

    func restore(products: [Product]) -> [CartItem] {
        if !hasRestored {
            cart = repository.load(for: products.map(\.id))
            hasRestored = true
        }
        self.products = products
        return currentItems
    }

    func changeQuantity(of productID: String, by delta: Int) -> [CartItem] {
        updateCart { $0.changeQuantity(of: productID, by: delta) }
    }

    func select(_ selected: Bool, productID: String? = nil) -> [CartItem] {
        updateCart { $0.setSelected(selected, productID: productID) }
    }

    func removeSelected() -> [CartItem] {
        updateCart { $0.removeSelected() }
    }

    /// Applies `change` to the cart, persists the result, then returns the new items.
    private func updateCart(_ change: (inout Cart) -> Void) -> [CartItem] {
        // Commands before the initial catalog arrives must not overwrite persisted entries.
        guard hasRestored else { return currentItems }
        change(&cart)
        repository.save(cart)
        return currentItems
    }

    private var currentItems: [CartItem] {
        cart.items(for: products)
    }
}
