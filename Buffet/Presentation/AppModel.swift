import Observation

/// Composes the feature stores and owns the workflows that span them.
///
/// Accepting a catalog also refreshes the cart annotations, which is the only place the two
/// features meet. The stores stay independent: each owns its own state and its own use case.
@Observable
@MainActor
final class AppModel {
    let catalog: CatalogStore
    let cart: CartStore

    init(catalog: CatalogStore, cart: CartStore) {
        self.catalog = catalog
        self.cart = cart
    }

    /// Both stores commit in one main-actor turn after the request is validated.
    func loadCatalog() async {
        await catalog.load { products in
            cart.updateProducts(products)
        }
    }
}
