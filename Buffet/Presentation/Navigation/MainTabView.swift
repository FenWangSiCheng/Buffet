import SwiftUI

struct MainTabView: View {
    @Environment(AppModel.self) private var app
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("首页", systemImage: "house.fill", value: AppTab.home) {
                ProductListView()
            }

            Tab("购物车", systemImage: "cart.fill", value: AppTab.cart) {
                CartView()
            }
            .badge(app.cart.itemCount)
        }
        .tint(.orange)
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environment(AppModel.preview())
}
#endif
