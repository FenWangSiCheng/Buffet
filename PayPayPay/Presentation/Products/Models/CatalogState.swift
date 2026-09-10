struct CatalogState {
    var items: [CartItem] = []
    var isLoading = false
    var errorMessage: String?

    var cartItems: [CartItem] { items.filter { $0.quantity > 0 } }
    var cartItemCount: Int { cartItems.count }
    var hasSelection: Bool { cartItems.contains { $0.isSelected } }
    var totalPrice: Money { cartItems.filter(\.isSelected).reduce(.zero) { $0 + $1.subtotal } }
    var isAllSelected: Bool { !cartItems.isEmpty && cartItems.allSatisfy { $0.isSelected } }
    var isShowingError: Bool { errorMessage != nil }
}
