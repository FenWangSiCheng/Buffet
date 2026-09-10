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

    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }

            CartView()
                .tabItem {
                    Label("购物车", systemImage: "cart.fill")
                }
                .badge(viewModel.state.cartItemCount)
        }
        .tint(.orange)
    }
}
