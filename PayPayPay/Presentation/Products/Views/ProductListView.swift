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

    private var filteredItems: [CartItem] {
        viewModel.state.items.filter {
            searchText.isEmpty || $0.nameText.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    SearchBarView(text: $searchText)
                        .padding(.top, 10)

                    List(filteredItems) { model in
                        ProductRowView(model: model)
                    }
                    .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))
                }

                VStack {
                    Spacer()
                    Label("扫二维码", systemImage: "qrcode.viewfinder")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(width: 120, height: 40)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    Spacer().frame(height: 10)
                }

                ActivityIndicatorView(isAnimating: viewModel.state.isLoading)
            }
            .navigationBarTitle("首页", displayMode: .inline)
        }
        .onAppear { viewModel.dispatch(.loadProducts) }
        .toast(
            isShowing: Binding(
                get: { viewModel.state.isShowingError },
                set: { if !$0 { viewModel.dismissError() } }
            ),
            text: Text(viewModel.state.error?.errorDescription() ?? "")
        )
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
