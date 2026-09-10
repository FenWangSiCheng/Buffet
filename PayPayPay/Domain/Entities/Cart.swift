struct Cart: Equatable, Sendable {
    struct Entry: Equatable, Sendable {
        let quantity: Int
        let isSelected: Bool

        init(quantity: Int, isSelected: Bool) {
            let normalizedQuantity = max(0, quantity)
            self.quantity = normalizedQuantity
            self.isSelected = normalizedQuantity > 0 && isSelected
        }
    }

    private(set) var entries: [String: Entry]

    init(entries: [String: Entry] = [:]) {
        self.entries = entries.filter { $0.value.quantity > 0 }
    }

    func items(for products: [Product]) -> [CartItem] {
        products.map { product in
            let entry = entries[product.id]
            return CartItem(product: product,
                            quantity: entry?.quantity ?? 0,
                            isSelected: entry?.isSelected ?? false)
        }
    }

    mutating func changeQuantity(of productID: String, by delta: Int) {
        let current = entries[productID] ?? Entry(quantity: 0, isSelected: false)
        let quantity = max(0, current.quantity + delta)
        if quantity == 0 {
            entries.removeValue(forKey: productID)
        } else {
            entries[productID] = Entry(quantity: quantity, isSelected: current.isSelected)
        }
    }

    mutating func setSelected(_ selected: Bool, productID: String? = nil) {
        for id in entries.keys where productID == nil || productID == id {
            guard let entry = entries[id] else { continue }
            entries[id] = Entry(quantity: entry.quantity, isSelected: selected)
        }
    }

    mutating func removeSelected() {
        entries = entries.filter { !$0.value.isSelected }
    }
}
