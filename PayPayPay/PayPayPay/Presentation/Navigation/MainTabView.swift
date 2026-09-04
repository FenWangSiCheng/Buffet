//
//  MainTabView.swift
//  PayPayPay
//
//  Created by Wang Wei on 2019/09/02.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    private var badgePosition: CGFloat = 2
    private var tabsCount: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
               TabView {
                    ProductListView().tabItem {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("首页")
                    }
                   CartView().tabItem {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("购物车")
                    }
                }
                .accentColor(.orange)

                ZStack {
                    Circle()
                        .foregroundColor(.red)

                    Text("\(self.viewModel.state.cartItemCount)")
                        .foregroundColor(.white)
                        .font(Font.system(size: 12))
                }
                .frame(width: 20, height: 20)
                .offset(x: ( ( 2 * self.badgePosition) - 1 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ), y: -30)
                .opacity(self.viewModel.state.cartItemCount == 0 ? 0 : 1)
            }
        }
    }

}
