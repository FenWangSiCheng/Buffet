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
    @Binding var isEdited: Bool
    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            HStack {
                if viewModel.state.isAllSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                Text("全选")
                    .font(.footnote)
            }.onTapGesture {
                if self.viewModel.state.isAllSelected {
                    self.viewModel.dispatch(.deselectAll)
                } else {
                    self.viewModel.dispatch(.selectAll)
                }
            }
            if isEdited {

            } else {
                Text("合计：\(viewModel.state.totalPrice.stringToPrice())")
                    .font(.footnote)
            }
            Spacer()
            Text(isEdited ? "删 除" : "付 款")
                .font(.footnote)
                .foregroundColor(viewModel.state.hasSelection ? .black :.white)
                .frame(width: 120, height: 30, alignment: .center)
                .background(viewModel.state.hasSelection ? Color.red : Color.gray)
                .cornerRadius(15)
                .onTapGesture {
                    if self.isEdited {
                        self.viewModel.dispatch(.removeSelected)
                    }else {

                    }
                }
            Spacer().frame(width: 20)
        }.frame(height: 50)
    }
}
