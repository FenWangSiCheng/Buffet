import Foundation

/// Everything the catalog and cart screens render, derived from `items` and `searchText`.
struct CatalogState {
    /// The full catalog, as returned by the backend.
    private(set) var items: [CartItem] = []
    /// The catalog's current search term.
    private(set) var searchText = ""

    /// Products matching the current search term, in catalog order.
    private(set) var visibleItems: [CartItem] = []
    /// Products the customer has added to the cart.
    private(set) var cartItems: [CartItem] = []
    private(set) var cartItemCount = 0
    private(set) var hasSelection = false
    private(set) var isAllSelected = false
    private(set) var totalPrice: Money = .zero

    var isLoading = false
    var errorMessage: String?

    var isShowingError: Bool { errorMessage != nil }

    mutating func setItems(_ newItems: [CartItem]) {
        items = newItems
        recomputeDerivedValues()
    }

    mutating func setSearchText(_ text: String) {
        searchText = text
        recomputeDerivedValues()
    }

    /// Rebuilds every derived value, so view bodies never have to filter or reduce.
    private mutating func recomputeDerivedValues() {
        visibleItems = items.filter { searchText.isEmpty || $0.nameText.localizedStandardContains(searchText) }
        cartItems = items.filter { $0.quantity > 0 }

        let selectedItems = cartItems.filter(\.isSelected)
        cartItemCount = cartItems.count
        hasSelection = !selectedItems.isEmpty
        isAllSelected = !cartItems.isEmpty && selectedItems.count == cartItems.count
        totalPrice = selectedItems.reduce(Money.zero) { $0 + $1.subtotal }
    }
}
