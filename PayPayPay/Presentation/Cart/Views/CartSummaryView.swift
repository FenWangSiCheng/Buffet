//
//  CartSummaryView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/31.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct CartSummaryView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @Binding var isEditing: Bool

    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            Button {
                viewModel.dispatch(viewModel.state.isAllSelected ? .deselectAll : .selectAll)
            } label: {
                HStack {
                    Image(systemName: viewModel.state.isAllSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(viewModel.state.isAllSelected ? .red : .gray)
                    Text("全选")
                        .font(.footnote)
                }
            }
            .buttonStyle(.plain)

            if !isEditing {
                Text("合计：\(viewModel.state.totalPrice.formattedPrice)")
                    .font(.footnote)
            }

            Spacer()

            Button(isEditing ? "删 除" : "付 款") {
                if isEditing {
                    viewModel.dispatch(.removeSelected)
                }
            }
            .font(.footnote)
            .foregroundColor(viewModel.state.hasSelection ? .black : .white)
            .frame(width: 120, height: 30)
            .background(viewModel.state.hasSelection ? Color.red : Color.gray)
            .clipShape(Capsule())
            .disabled(!viewModel.state.hasSelection)

            Spacer().frame(width: 20)
        }
        .frame(height: 50)
    }
}
