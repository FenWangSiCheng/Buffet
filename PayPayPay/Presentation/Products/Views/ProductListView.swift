//
//  ProductListView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/18.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                ZStack {
                    VStack {
                        SearchBarView(text: $searchText)
                            .padding(.top, 10)

                        List(viewModel.state.items.filter {
                            searchText.isEmpty || $0.nameText.contains(searchText)
                        }) { model in
                            ProductRowView(model: model)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        })
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 25, weight: .regular))
                                .foregroundColor(.black)
                            Text("扫二维码")
                                .font(.subheadline)
                                .foregroundColor(.black)

                        }
                        .frame(width: 120, height: 40)
                        .background(Color.orange)
                        .cornerRadius(20)
                        Spacer().frame(height: 10)
                    }
                }

                ActivityIndicatorView(isAnimating: viewModel.state.isLoading, style: .large)
                    .onAppear {
                        self.viewModel.dispatch(.loadProducts)
                }
            }
             .navigationBarTitle("首页", displayMode: .inline)

        }
        .toast(
            isShowing: Binding(
                get: { viewModel.state.isShowingError },
                set: { if !$0 { viewModel.dismissError() } }
            ),
            text: Text(viewModel.state.error?.errorDescription() ?? "")
        )
    }
}
