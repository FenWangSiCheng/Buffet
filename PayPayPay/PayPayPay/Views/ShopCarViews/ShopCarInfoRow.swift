//
//  ShopCarInfoRow.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/28.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ShopCarInfoRow: View {
    @EnvironmentObject var store: Store
    let model: ProductInfoModel
    var body: some View {
        HStack {
            if model.isSelected {

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.red)
                    .onTapGesture {
                        self.store.dispatch(.canceledGood(model: self.model))
                    }
            } else {

                Image(systemName: "circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        self.store.dispatch(.selectedGood(model: self.model))
                    }
            }

            GoodInfoRow(model: model)

        }
    }
}
