import SwiftUI

struct CartSummaryView: View {
    @Binding var isEditing: Bool
    let isAllSelected: Bool
    let totalPrice: Money
    let hasSelection: Bool
    let onToggleAll: () -> Void
    let onRemoveSelected: () -> Void
    let onCheckout: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleAll) {
                Label("全选", systemImage: isAllSelected ? "checkmark.circle.fill" : "circle")
                    .font(.footnote)
            }
            .buttonStyle(.plain)
            .foregroundStyle(isAllSelected ? Color.red : Color.secondary)
            .frame(minHeight: Theme.minimumTapSize)

            if !isEditing {
                Text("合计：\(totalPrice.amount, format: Money.currencyFormat)")
                    .font(.footnote)
            }

            Spacer(minLength: 0)

            Button(isEditing ? "删 除" : "付 款",
                   action: isEditing ? onRemoveSelected : onCheckout)
                .font(.footnote)
                .buttonStyle(.borderedProminent)
                .tint(hasSelection ? .red : .gray)
                .disabled(!hasSelection)
                .frame(minHeight: Theme.minimumTapSize)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}
