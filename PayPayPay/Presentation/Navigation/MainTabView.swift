import SwiftUI

struct MainTabView: View {
    @Environment(CatalogViewModel.self) private var viewModel
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("首页", systemImage: "house.fill", value: AppTab.home) {
                ProductListView()
            }

            Tab("购物车", systemImage: "cart.fill", value: AppTab.cart) {
                CartView()
            }
            .badge(viewModel.state.cartItemCount)
        }
        .tint(.orange)
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environment(CatalogViewModel.preview())
}
#endif
