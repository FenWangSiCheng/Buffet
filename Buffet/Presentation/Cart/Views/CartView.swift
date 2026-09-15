import SwiftUI

struct CartView: View {
    @Environment(CatalogViewModel.self) private var viewModel
    @State private var isEditing = false
    @State private var isShowingCheckoutNotice = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.state.cartItems.isEmpty {
                    ContentUnavailableView(
                        "购物车空空如也，去逛逛吧~",
                        systemImage: "cart.badge.plus"
                    )
                } else {
                    List(viewModel.state.cartItems) { item in
                        CartRowView(
                            model: item,
                            onToggleSelection: { toggleSelection(of: item) },
                            onDecrease: { decreaseQuantity(of: item) },
                            onIncrease: { increaseQuantity(of: item) }
                        )
                    }
                    .listStyle(.plain)

                    CartSummaryView(
                        isEditing: $isEditing,
                        isAllSelected: viewModel.state.isAllSelected,
                        totalPrice: viewModel.state.totalPrice,
                        hasSelection: viewModel.state.hasSelection,
                        onToggleAll: { toggleAllSelection() },
                        onRemoveSelected: { removeSelected() },
                        onCheckout: { isShowingCheckoutNotice = true }
                    )
                }
            }
            .navigationTitle("商品")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "完成" : "编辑") { isEditing.toggle() }
                        .foregroundStyle(Color.textHeaderPrimary)
                }
            }
            .alert("付款功能即将上线", isPresented: $isShowingCheckoutNotice) { }
        }
    }

    private func toggleSelection(of item: CartItem) {
        Task { await viewModel.setItemSelected(!item.isSelected, productID: item.id) }
    }

    private func increaseQuantity(of item: CartItem) {
        Task { await viewModel.increaseQuantity(productID: item.id) }
    }

    private func decreaseQuantity(of item: CartItem) {
        Task { await viewModel.decreaseQuantity(productID: item.id) }
    }

    private func toggleAllSelection() {
        Task { await viewModel.setAllSelected(!viewModel.state.isAllSelected) }
    }

    private func removeSelected() {
        Task { await viewModel.removeSelected() }
    }
}

#if DEBUG
#Preview {
    CartView()
        .environment(CatalogViewModel.preview())
}
#endif
