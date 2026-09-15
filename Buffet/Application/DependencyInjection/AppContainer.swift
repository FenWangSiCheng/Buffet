import Foundation
import Moya

/// The only place that assembles concrete data adapters for the application.
@MainActor
enum AppContainer {
    static func makeAppModel(defaults: UserDefaults = .standard) -> AppModel {
        // Preserve the demo's delayed fixture responses; there is no live backend configured.
        let provider = MoyaProvider<ProductEndpoint>(stubClosure: MoyaProvider.delayedStub(3))
        let client = ProductAPIClient(provider: provider)
        let products = RemoteProductRepository(client: client, baseURL: AppEnvironment.apiBaseURL)
        let cart = ManageCartUseCase(repository: UserDefaultsCartRepository(defaults: defaults))
        let loadProducts = LoadProductsUseCase(repository: products, cart: cart)
        return AppModel(catalog: CatalogStore(loadProducts: loadProducts),
                        cart: CartStore(manageCart: cart))
    }
}
