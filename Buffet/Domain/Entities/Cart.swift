struct Cart: Equatable, Sendable {
    struct Entry: Equatable, Sendable {
        /// An entry for a product that is not in the cart.
        static let empty = Entry(quantity: 0, isSelected: false)

        let quantity: Int
        let isSelected: Bool

        init(quantity: Int, isSelected: Bool) {
            let normalizedQuantity = max(0, quantity)
            self.quantity = normalizedQuantity
            self.isSelected = normalizedQuantity > 0 && isSelected
        }

        /// The same quantity, with the selection flag replaced.
        func selecting(_ selected: Bool) -> Entry {
            Entry(quantity: quantity, isSelected: selected)
        }
    }

    private(set) var entries: [String: Entry]

    init(entries: [String: Entry] = [:]) {
        self.entries = entries.filter { $0.value.quantity > 0 }
    }

    func items(for products: [Product]) -> [CartItem] {
        products.map { product in
            let entry = entries[product.id] ?? .empty
            return CartItem(product: product,
                            quantity: entry.quantity,
                            isSelected: entry.isSelected)
        }
    }

    mutating func changeQuantity(of productID: String, by delta: Int) {
        let current = entries[productID] ?? .empty
        let quantity = max(0, current.quantity + delta)
        guard quantity > 0 else {
            entries.removeValue(forKey: productID)
            return
        }
        entries[productID] = Entry(quantity: quantity, isSelected: current.isSelected)
    }

    mutating func setSelected(_ selected: Bool, productID: String? = nil) {
        guard let productID else {
            entries = entries.mapValues { $0.selecting(selected) }
            return
        }
        guard let entry = entries[productID] else { return }
        entries[productID] = entry.selecting(selected)
    }

    mutating func removeSelected() {
        entries = entries.filter { !$0.value.isSelected }
    }
}
