//
//  GoodInfoRow.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/19.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI

struct GoodInfoRow: View {
    @EnvironmentObject var store: Store
     @State private var showingAlert = false
    let model: ProductInfoModel

    var body: some View {
        
        HStack {
            KFImage(self.model.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                HStack {
                    Text(self.model.goodNameStr ?? "")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(UIColor.textHeaderPrimary)
                    Spacer()
                    
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(self.model.soldStr)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer().frame(height: 20)
                HStack {
                    Text(self.model.priceStr)
                        .font(.footnote)
                    Text(self.model.oriPriceStr)
                        .font(.footnote)
                        .strikethrough()
                        .foregroundColor(.gray)
                    Spacer()
                    if self.model.shopCarCount <= 0 {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.store.dispatch(.addShopCar(model: self.model))
                        }
                    } else {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.store.dispatch(.subShopCar(model: self.model))
                        }
                        
                        Text(self.model.shopCarCountStr)
                            .font(.footnote)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.orange)
                            .onTapGesture {
                                self.store.dispatch(.addShopCar(model: self.model))
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

