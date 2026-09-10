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
        cart.changeQuantity(of: productID, by: delta)
        await repository.save(cart)
        return currentItems
    }

    func select(_ selected: Bool, productID: String? = nil) async -> [CartItem] {
        cart.setSelected(selected, productID: productID)
        await repository.save(cart)
        return currentItems
    }

    func removeSelected() async -> [CartItem] {
        cart.removeSelected()
        await repository.save(cart)
        return currentItems
    }

    private var currentItems: [CartItem] {
        cart.items(for: products)
    }
}
