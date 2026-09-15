import SwiftUI

@main
struct BuffetApp: App {
    @State private var app = AppContainer.makeAppModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(app)
        }
    }
}
