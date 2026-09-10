//
//  ProductRowView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/19.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ProductRowView: View {
    let model: CartItem
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {

        HStack {
            KFImage(model.imageURL)
                .resizable().scaledToFit()
            VStack {
                HStack {
                    Text(self.model.nameText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(.textHeaderPrimary)
                    Spacer()

                }
                Spacer().frame(height: 5)
                HStack {
                    Text(self.model.soldText)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer().frame(height: 20)
                HStack {
                    Text(self.model.priceText)
                        .font(.footnote)
                    Text(self.model.originalPriceText)
                        .font(.footnote)
                        .strikethrough()
                        .foregroundColor(.gray)
                    Spacer()
                    if model.quantity > 0 {
                        quantityButton(systemImage: "minus.circle.fill", label: "减少数量",
                                       action: onDecrease)

                        Text(model.quantityText)
                            .font(.footnote)
                    }

                    quantityButton(systemImage: "plus.circle.fill", label: "增加数量",
                                   action: onIncrease)
                }
            }
            Spacer()
        }
        .padding(10)
        .frame(height: 150)
    }

    private func quantityButton(systemImage: String, label: String,
                                action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundColor(.orange)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
