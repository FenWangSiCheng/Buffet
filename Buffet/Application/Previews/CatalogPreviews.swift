#if DEBUG
import SwiftUI

extension AppModel {
    /// An app model backed by the bundled fixture data, for previews only.
    static func preview() -> AppModel {
        AppContainer.makeAppModel(
            defaults: UserDefaults(suiteName: "Buffet.Previews") ?? .standard
        )
    }
}

#Preview("Catalog - dark") {
    MainTabView()
        .environment(AppModel.preview())
        .preferredColorScheme(.dark)
}
#endif
