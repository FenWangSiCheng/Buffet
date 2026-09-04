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
        items.map { item in
            guard item.id == productID else { return item }
            var updated = item
            updated.quantity = max(0, item.quantity + delta)
            if updated.quantity == 0 { updated.isSelected = false }
            persist(updated)
            return updated
        }
    }

    func select(_ selected: Bool, productID: String? = nil, in items: [CartItem]) -> [CartItem] {
        items.map { item in
            guard productID == nil || item.id == productID else { return item }
            var updated = item
            updated.isSelected = selected && item.quantity > 0
            persist(updated)
            return updated
        }
    }

    func removeSelected(from items: [CartItem]) -> [CartItem] {
        items.map { item in
            guard item.isSelected else { return item }
            var updated = item
            updated.quantity = 0
            updated.isSelected = false
            persist(updated)
            return updated
        }
    }

    private func persist(_ item: CartItem) {
        repository.setCount(item.quantity, for: item.id)
        repository.setSelected(item.isSelected, for: item.id)
    }
}
