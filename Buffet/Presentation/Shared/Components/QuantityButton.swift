import SwiftUI

/// A circular icon button that adjusts a cart line's quantity.
struct QuantityButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(label, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundStyle(.orange)
            .buttonStyle(.plain)
            .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
    }
}
