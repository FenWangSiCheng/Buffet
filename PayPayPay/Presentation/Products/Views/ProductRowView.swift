import Kingfisher
import SwiftUI

struct ProductRowView: View {
    let model: CartItem
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            KFImage(model.product.imageURL)
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFit()
                .frame(width: Theme.thumbnailSize, height: Theme.thumbnailSize)

            VStack(alignment: .leading, spacing: 6) {
                Text(model.nameText)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(Color.textHeaderPrimary)

                Text(model.soldText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                HStack(spacing: 8) {
                    ProductPriceView(price: model.product.price,
                                     originalPrice: model.product.originalPrice)
                    Spacer(minLength: 0)

                    if model.quantity > 0 {
                        QuantityButton(systemImage: "minus.circle.fill",
                                       label: "减少数量",
                                       action: onDecrease)
                        Text(model.quantityText)
                            .font(.footnote)
                            .monospacedDigit()
                    }

                    QuantityButton(systemImage: "plus.circle.fill",
                                   label: "增加数量",
                                   action: onIncrease)
                }
            }
        }
        .padding(Theme.rowPadding)
    }
}
