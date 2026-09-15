import SwiftUI

struct CartView: View {
    @Environment(AppModel.self) private var app
    @State private var isEditing = false
    @State private var isShowingCheckoutNotice = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if app.cart.cartItems.isEmpty {
                    ContentUnavailableView(
                        "购物车空空如也，去逛逛吧~",
                        systemImage: "cart.badge.plus"
                    )
                } else {
                    List(app.cart.cartItems) { item in
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
                        isAllSelected: app.cart.isAllSelected,
                        totalPrice: app.cart.totalPrice,
                        hasSelection: app.cart.hasSelection,
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
        Task { await app.cart.setSelected(!item.isSelected, productID: item.id) }
    }

    private func increaseQuantity(of item: CartItem) {
        Task { await app.cart.increaseQuantity(of: item.id) }
    }

    private func decreaseQuantity(of item: CartItem) {
        Task { await app.cart.decreaseQuantity(of: item.id) }
    }

    private func toggleAllSelection() {
        Task { await app.cart.setAllSelected(!app.cart.isAllSelected) }
    }

    private func removeSelected() {
        Task { await app.cart.removeSelected() }
    }
}

#if DEBUG
#Preview {
    CartView()
        .environment(AppModel.preview())
}
#endif
