import SwiftUI

@main
struct BuffetApp: App {
    @State private var viewModel = AppContainer.makeCatalogViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(viewModel)
        }
    }
}
