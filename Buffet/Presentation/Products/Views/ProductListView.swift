import SwiftUI

struct ProductListView: View {
    @Environment(CatalogViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            List(viewModel.state.visibleItems) { item in
                ProductRowView(
                    model: item,
                    onDecrease: { decreaseQuantity(of: item) },
                    onIncrease: { increaseQuantity(of: item) }
                )
            }
            .listStyle(.plain)
            .overlay { emptyState }
            .safeAreaInset(edge: .bottom) { scanBadge }
            .navigationTitle("首页")
            .searchable(text: $viewModel.searchText, prompt: Text("搜索商品"))
            .overlay { ActivityIndicatorView(isAnimating: viewModel.state.isLoading) }
            .task { await viewModel.load() }
            .toast(message: viewModel.state.errorMessage) { viewModel.dismissError() }
        }
    }

    /// Shown while the list has nothing to display, except when a request is still in flight.
    @ViewBuilder
    private var emptyState: some View {
        if viewModel.state.visibleItems.isEmpty, !viewModel.state.isLoading {
            if viewModel.state.searchText.isEmpty {
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

    private func increaseQuantity(of item: CartItem) {
        Task { await viewModel.increaseQuantity(productID: item.id) }
    }

    private func decreaseQuantity(of item: CartItem) {
        Task { await viewModel.decreaseQuantity(productID: item.id) }
    }
}

#if DEBUG
#Preview {
    ProductListView()
        .environment(CatalogViewModel.preview())
}
#endif
