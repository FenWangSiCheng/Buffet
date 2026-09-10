@MainActor
struct ManageCartUseCase {
    let repository: CartRepository

    func restore(products: [Product]) -> [CartItem] {
        products.map { product in
            let quantity = max(0, repository.count(for: product.id))
            return CartItem(product: product, quantity: quantity,
                            isSelected: quantity > 0 && repository.isSelected(for: product.id))
        }
    }

    func changeQuantity(of productID: String, by delta: Int, in items: [CartItem]) -> [CartItem] {
        update(items, where: { $0.id == productID }, transform: { item in
            item.quantity = max(0, item.quantity + delta)
            if item.quantity == 0 {
                item.isSelected = false
            }
        })
    }

    func select(_ selected: Bool, productID: String? = nil, in items: [CartItem]) -> [CartItem] {
        update(items, where: { productID == nil || $0.id == productID }, transform: { item in
            item.isSelected = selected && item.quantity > 0
        })
    }

    func removeSelected(from items: [CartItem]) -> [CartItem] {
        update(items, where: \.isSelected) { item in
            item.quantity = 0
            item.isSelected = false
        }
    }

    private func update(_ items: [CartItem], where shouldUpdate: (CartItem) -> Bool,
                        transform: (inout CartItem) -> Void) -> [CartItem] {
        items.map { item in
            guard shouldUpdate(item) else { return item }
            var updated = item
            transform(&updated)
            persist(updated)
            return updated
        }
    }

    private func persist(_ item: CartItem) {
        repository.setCount(item.quantity, for: item.id)
        repository.setSelected(item.isSelected, for: item.id)
    }
}
