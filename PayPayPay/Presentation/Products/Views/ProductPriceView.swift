import SwiftUI

/// A product's price, with the original price struck through when it is discounted.
struct ProductPriceView: View {
    let price: Money
    let originalPrice: Money?

    var body: some View {
        HStack(spacing: 6) {
            Text(price.amount, format: Money.currencyFormat)
                .font(.footnote)

            if let originalPrice {
                Text(originalPrice.amount, format: Money.currencyFormat)
                    .font(.footnote)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
        }
    }
}
