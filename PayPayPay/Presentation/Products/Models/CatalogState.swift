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

    /// Rebuilds every derived value in one pass, so view bodies never have to filter or reduce.
    private mutating func recomputeDerivedValues() {
        var visible: [CartItem] = []
        var cart: [CartItem] = []
        var hasSelection = false
        var allSelected = true
        var total = Money.zero

        for item in items {
            if searchText.isEmpty || item.nameText.localizedStandardContains(searchText) {
                visible.append(item)
            }
            guard item.quantity > 0 else { continue }
            cart.append(item)
            if item.isSelected {
                hasSelection = true
                total += item.subtotal
            } else {
                allSelected = false
            }
        }

        visibleItems = visible
        cartItems = cart
        cartItemCount = cart.count
        self.hasSelection = hasSelection
        isAllSelected = !cart.isEmpty && allSelected
        totalPrice = total
    }
}
