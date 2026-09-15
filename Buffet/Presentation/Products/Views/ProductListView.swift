import SwiftUI

struct ProductListView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var catalog = app.catalog

        NavigationStack {
            List(app.catalog.visibleProducts) { product in
                ProductRowView(
                    model: app.cart.item(for: product),
                    onDecrease: { decreaseQuantity(of: product) },
                    onIncrease: { increaseQuantity(of: product) }
                )
            }
            .listStyle(.plain)
            .overlay { emptyState }
            .safeAreaInset(edge: .bottom) { scanBadge }
            .navigationTitle("首页")
            .searchable(text: $catalog.searchText, prompt: Text("搜索商品"))
            .overlay { ActivityIndicatorView(isAnimating: app.catalog.isLoading) }
            .task { await app.loadCatalog() }
            .toast(message: app.catalog.errorMessage) { app.catalog.dismissError() }
        }
    }

    /// Shown while the list has nothing to display, except when a request is still in flight.
    @ViewBuilder
    private var emptyState: some View {
        if app.catalog.visibleProducts.isEmpty, !app.catalog.isLoading {
            if app.catalog.searchText.isEmpty {
                ContentUnavailableView("暂无商品",
                                       systemImage: "bag",
                                       description: Text("下拉刷新试试"))
            } else {
                ContentUnavailableView.search
            }
        }
    }

    /// The scan entry point, which stays a placeholder until scanning ships.
    private var scanBadge: some View {
        Label("扫二维码", systemImage: "qrcode.viewfinder")
            .font(.subheadline)
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.orange, in: .capsule)
            .padding(.bottom, 10)
    }

    private func increaseQuantity(of product: Product) {
        Task { await app.cart.increaseQuantity(of: product.id) }
    }

    private func decreaseQuantity(of product: Product) {
        Task { await app.cart.decreaseQuantity(of: product.id) }
    }
}

#if DEBUG
#Preview {
    ProductListView()
        .environment(AppModel.preview())
}
#endif
