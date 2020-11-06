//
//  ShopCar.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/27.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ShopCar: View {
    @EnvironmentObject var store: Store
    @State var isEdited: Bool = false

    var body: some View {
        let goods = store.appState.goodList.goods?.filter { $0.shopCarCount > 0 } ?? []
        NavigationView {
            if goods.count == 0 {
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
                    List(goods) { (model) in
                        ShopCarInfoRow(model: model)
                    }

                    ShopCarBottom(isEdited: $isEdited)
                }
                .navigationBarItems(trailing:
                    Button(action: {

                        self.isEdited = !self.isEdited
                    }, label: {
                        
                        Text(self.isEdited ? "完成" : "编辑")
                            .foregroundColor(UIColor.textHeaderPrimary)
                    })

                )
                .navigationBarTitle("商品", displayMode: .inline)

            }

        }
    }
}

struct ShopCar_Previews: PreviewProvider {
    static var previews: some View {
        ShopCar().environmentObject(Store())
    }
}
