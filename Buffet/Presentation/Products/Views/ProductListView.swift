import SwiftUI

struct ProductListView: View {
    @Environment(AppModel.self) private var app
    @State private var isShowingScanNotice = false

    var body: some View {
        @Bindable var catalog = app.catalog

        NavigationStack {
            List(catalog.visibleProducts) { product in
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
            .overlay { ActivityIndicatorView(isAnimating: catalog.isLoading) }
            .alert("扫码功能即将上线", isPresented: $isShowingScanNotice) { }
            .task { await app.loadCatalog() }
            .toast(message: catalog.errorMessage) { catalog.dismissError() }
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
        Button("扫二维码", systemImage: "qrcode.viewfinder", action: showScanNotice)
            .font(.subheadline)
            .controlSize(.large)
            .adaptiveProminentButtonStyle(tint: .orange)
            .padding(.bottom, 10)
    }

    private func showScanNotice() {
        isShowingScanNotice = true
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
