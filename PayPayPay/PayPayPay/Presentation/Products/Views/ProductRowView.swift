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
    @EnvironmentObject var viewModel: CatalogViewModel
     @State private var showingAlert = false
    let model: CartItem

    var body: some View {

        HStack {
            KFImage(model.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                HStack {
                    Text(self.model.nameText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(UIColor.textHeaderPrimary)
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
                    if self.model.quantity <= 0 {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.viewModel.dispatch(.increaseQuantity(productID: self.model.id))
                        }
                    } else {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.viewModel.dispatch(.decreaseQuantity(productID: self.model.id))
                        }

                        Text(self.model.quantityText)
                            .font(.footnote)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.viewModel.dispatch(.increaseQuantity(productID: self.model.id))
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(10)
        .frame(height: 150)
    }
}
