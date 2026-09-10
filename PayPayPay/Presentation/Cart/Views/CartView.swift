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
                        CartRowView(
                            model: model,
                            onToggleSelection: {
                                Task {
                                    await viewModel.setItemSelected(!model.isSelected, productID: model.id)
                                }
                            },
                            onDecrease: {
                                Task { await viewModel.decreaseQuantity(productID: model.id) }
                            },
                            onIncrease: {
                                Task { await viewModel.increaseQuantity(productID: model.id) }
                            }
                        )
                    }

                    CartSummaryView(
                        isEditing: $isEditing,
                        isAllSelected: viewModel.state.isAllSelected,
                        totalPrice: viewModel.state.totalPrice,
                        hasSelection: viewModel.state.hasSelection,
                        onToggleAll: {
                            Task { await viewModel.setAllSelected(!viewModel.state.isAllSelected) }
                        },
                        onRemoveSelected: {
                            Task { await viewModel.removeSelected() }
                        }
                    )
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
