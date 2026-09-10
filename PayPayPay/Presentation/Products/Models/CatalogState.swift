struct CatalogState {
    var items: [CartItem] = []
    var isLoading = false
    var error: RepositoryError?

    var cartItems: [CartItem] { items.filter { $0.quantity > 0 } }
    var cartItemCount: Int { cartItems.count }
    var hasSelection: Bool { cartItems.contains { $0.isSelected } }
    var totalPrice: Double { cartItems.filter { $0.isSelected }.reduce(0) { $0 + $1.subtotal } }
    var isAllSelected: Bool { !cartItems.isEmpty && cartItems.allSatisfy { $0.isSelected } }
    var isShowingError: Bool { error != nil }
}
