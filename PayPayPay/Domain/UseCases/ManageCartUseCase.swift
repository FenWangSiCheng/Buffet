actor ManageCartUseCase {
    private let repository: any CartRepository
    private var products: [Product] = []
    private var cart = Cart()

    init(repository: any CartRepository) {
        self.repository = repository
    }

    func restore(products: [Product]) async -> [CartItem] {
        let restored = await repository.load(for: products.map(\.id))
        self.products = products
        cart = restored
        return currentItems
    }

    func changeQuantity(of productID: String, by delta: Int) async -> [CartItem] {
        await updateCart { $0.changeQuantity(of: productID, by: delta) }
    }

    func select(_ selected: Bool, productID: String? = nil) async -> [CartItem] {
        await updateCart { $0.setSelected(selected, productID: productID) }
    }

    func removeSelected() async -> [CartItem] {
        await updateCart { $0.removeSelected() }
    }

    /// Applies `change` to the cart, persists the result, then returns the new items.
    private func updateCart(_ change: (inout Cart) -> Void) async -> [CartItem] {
        change(&cart)
        await repository.save(cart)
        return currentItems
    }

    private var currentItems: [CartItem] {
        cart.items(for: products)
    }
}
