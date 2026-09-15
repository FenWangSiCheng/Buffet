#if DEBUG
import SwiftUI

extension CatalogViewModel {
    /// A view model backed by the bundled fixture data, for previews only.
    static func preview() -> CatalogViewModel {
        AppContainer.makeCatalogViewModel(
            defaults: UserDefaults(suiteName: "Buffet.Previews") ?? .standard
        )
    }
}

#Preview("Catalog - dark") {
    MainTabView()
        .environment(CatalogViewModel.preview())
        .preferredColorScheme(.dark)
}
#endif
