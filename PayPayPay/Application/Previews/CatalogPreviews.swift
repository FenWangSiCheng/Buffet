#if DEBUG
import SwiftUI

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            MainTabView()
                .environment(\.colorScheme, .light)
                .previewDevice(PreviewDevice(rawValue: "iPhone X"))
                .environmentObject(AppContainer.makeCatalogViewModel(
                    defaults: UserDefaults(suiteName: "Buffet.Previews")!
                ))
            MainTabView()
                .environment(\.colorScheme, .dark)
                .previewDevice(PreviewDevice(rawValue: "iPhone X"))
                .environmentObject(AppContainer.makeCatalogViewModel(
                    defaults: UserDefaults(suiteName: "Buffet.Previews")!
                ))
            MainTabView()
                .environment(\.colorScheme, .light)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .environmentObject(AppContainer.makeCatalogViewModel(
                    defaults: UserDefaults(suiteName: "Buffet.Previews")!
                ))
        }

    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(AppContainer.makeCatalogViewModel(
                defaults: UserDefaults(suiteName: "Buffet.Previews")!
            ))
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
            .environmentObject(AppContainer.makeCatalogViewModel(
                defaults: UserDefaults(suiteName: "Buffet.Previews")!
            ))
    }
}

#endif
