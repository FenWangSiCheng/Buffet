//
//  CartRowView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/28.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct CartRowView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    let model: CartItem
    var body: some View {
        HStack {
            if model.isSelected {

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.red)
                    .onTapGesture {
                        self.viewModel.dispatch(.deselectItem(productID: self.model.id))
                    }
            } else {

                Image(systemName: "circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        self.viewModel.dispatch(.selectItem(productID: self.model.id))
                    }
            }

            ProductRowView(model: model)

        }
    }
}
