//
//  ShopCarBottom.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/31.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ShopCarBottom: View {
    @EnvironmentObject var store: Store
    @Binding var isEdited: Bool
    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            HStack {
                if store.appState.goodList.isAllSelected {
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
                if self.store.appState.goodList.isAllSelected {
                    self.store.dispatch(.canceledAllGoods)
                } else {
                    self.store.dispatch(.selectedAllGoods)
                }
            }
            if isEdited {

            } else {
                Text("合计：\(store.appState.goodList.totlaPrice.stringToPrice())")
                    .font(.footnote)
            }
            Spacer()
            Text(isEdited ? "删 除" : "付 款")
                .font(.footnote)
                .foregroundColor(store.appState.goodList.haveSelected ? .black :.white)
                .frame(width: 120, height: 30, alignment: .center)
                .background(store.appState.goodList.haveSelected ? Color.red : Color.gray)
                .cornerRadius(15)
                .onTapGesture {
                    if self.isEdited {
                        self.store.dispatch(.deletedSelectGood)
                    }else {

                    }
                }
            Spacer().frame(width: 20)
        }.frame(height: 50)
    }
}


