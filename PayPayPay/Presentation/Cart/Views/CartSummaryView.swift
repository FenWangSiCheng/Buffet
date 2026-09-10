//
//  CartSummaryView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/31.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct CartSummaryView: View {
    @Binding var isEditing: Bool
    let isAllSelected: Bool
    let totalPrice: Money
    let hasSelection: Bool
    let onToggleAll: () -> Void
    let onRemoveSelected: () -> Void

    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            Button {
                onToggleAll()
            } label: {
                HStack {
                    Image(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(isAllSelected ? .red : .gray)
                    Text("全选")
                        .font(.footnote)
                }
            }
            .buttonStyle(.plain)

            if !isEditing {
                Text("合计：\(totalPrice.formattedPrice)")
                    .font(.footnote)
            }

            Spacer()

            Button(isEditing ? "删 除" : "付 款") {
                if isEditing {
                    onRemoveSelected()
                }
            }
            .font(.footnote)
            .foregroundColor(hasSelection ? .black : .white)
            .frame(width: 120, height: 30)
            .background(hasSelection ? Color.red : Color.gray)
            .clipShape(Capsule())
            .disabled(!hasSelection)

            Spacer().frame(width: 20)
        }
        .frame(height: 50)
    }
}
