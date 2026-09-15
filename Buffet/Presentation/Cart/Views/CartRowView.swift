import SwiftUI

struct CartRowView: View {
    let model: CartItem
    let onToggleSelection: () -> Void
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button(model.isSelected ? "取消选择" : "选择商品",
                   systemImage: model.isSelected ? "checkmark.circle.fill" : "circle",
                   action: onToggleSelection)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(model.isSelected ? Color.red : Color.secondary)
                .buttonStyle(.plain)
                .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)

            ProductRowView(model: model, onDecrease: onDecrease, onIncrease: onIncrease)
        }
    }
}
