//
//  CartView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/27.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            if viewModel.state.cartItems.isEmpty {
                VStack {
                    Image(systemName: "cart.fill.badge.plus")
                        .font(.system(size: 100, weight: .regular))
                        .foregroundColor(.gray)
                    Spacer().frame(height: 40)
                    Text("购物车空空如也，去逛逛吧~")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .navigationBarTitle("商品", displayMode: .inline)
            } else {
                VStack {
                    List(viewModel.state.cartItems) { model in
                        CartRowView(model: model)
                    }

                    CartSummaryView(isEditing: $isEditing)
                }
                .navigationBarItems(trailing: Button(isEditing ? "完成" : "编辑") {
                    isEditing.toggle()
                }
                .foregroundColor(.textHeaderPrimary))
                .navigationBarTitle("商品", displayMode: .inline)
            }
        }
    }
}
