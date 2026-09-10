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
            Button {
                viewModel.dispatch(model.isSelected
                    ? .deselectItem(productID: model.id)
                    : .selectItem(productID: model.id))
            } label: {
                Image(systemName: model.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(model.isSelected ? .red : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(model.isSelected ? "取消选择" : "选择商品")

            ProductRowView(model: model)
        }
    }
}
