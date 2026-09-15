import Observation

/// Composes the feature stores and owns the workflows that span them.
///
/// Loading the catalog also refreshes the cart annotations, which is the only place the two
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

    /// Loads the catalog and hands the refreshed cart snapshot to the cart store.
    func loadCatalog() async {
        guard let snapshot = await catalog.load() else { return }
        cart.adopt(snapshot)
    }
}
