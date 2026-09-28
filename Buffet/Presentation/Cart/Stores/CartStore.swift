import Foundation
import Observation

/// The cart feature's state: which products the customer picked, how many, and what they cost.
///
/// Accepted catalog updates and cart commands commit synchronously on the main actor.
@Observable
@MainActor
final class CartStore {
    /// Every catalog product with its cart entry, joined with the current session cart.
    private(set) var items: [CartItem] = []
    /// Products the customer has added to the cart.
    private(set) var cartItems: [CartItem] = []
    private(set) var itemCount = 0
    private(set) var hasSelection = false
    private(set) var isAllSelected = false
    private(set) var totalPrice: Money = .zero

    private let manageCart: ManageCartUseCase
    private var itemsByID: [String: CartItem] = [:]

    init(manageCart: ManageCartUseCase) {
        self.manageCart = manageCart
    }

    /// The row model for a catalog product, so the list can show its quantity and selection.
    func item(for product: Product) -> CartItem {
        itemsByID[product.id] ?? CartItem(product: product)
    }

    /// Restores once, then joins accepted products with the current session cart.
    func updateProducts(_ products: [Product]) {
        setItems(manageCart.restore(products: products))
    }

    func increaseQuantity(of productID: String) {
        setItems(manageCart.changeQuantity(of: productID, by: 1))
    }

    func decreaseQuantity(of productID: String) {
        setItems(manageCart.changeQuantity(of: productID, by: -1))
    }

    func setSelected(_ selected: Bool, productID: String) {
        setItems(manageCart.select(selected, productID: productID))
    }

    func setAllSelected(_ selected: Bool) {
        setItems(manageCart.select(selected))
    }

    func removeSelected() {
        setItems(manageCart.removeSelected())
    }

    private func setItems(_ newItems: [CartItem]) {
        items = newItems
        itemsByID = Dictionary(uniqueKeysWithValues: newItems.map { ($0.id, $0) })
        recomputeCartValues()
    }

    /// Rebuilds every derived value, so view bodies never have to filter or reduce.
    private func recomputeCartValues() {
        cartItems = items.filter { $0.quantity > 0 }

        let selectedItems = cartItems.filter(\.isSelected)
        itemCount = cartItems.count
        hasSelection = !selectedItems.isEmpty
        isAllSelected = !cartItems.isEmpty && selectedItems.count == cartItems.count
        totalPrice = selectedItems.reduce(Money.zero) { $0 + $1.subtotal }
    }
}
