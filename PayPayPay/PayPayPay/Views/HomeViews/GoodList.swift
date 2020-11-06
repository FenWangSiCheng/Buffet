//
//  GoodList.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/18.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct GoodList: View {
    @EnvironmentObject var store: Store
    @State var searchText: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                ZStack {
                    VStack {
                        SearchBar(text: $searchText)
                            .padding(.top, 10)

                        List(self.store.appState.goodList.goods?.filter { searchText.isEmpty ? true : $0.goodNameStr!.contains(searchText)} ?? []) { ( model) in
                            GoodInfoRow(model: model)
                        }
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
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

                ActivityIndicator(isAnimating: $store.appState.goodList.loadingGoods, style: .large)
                    .onAppear {
                        self.store.dispatch(.loadGoods)
                }
            }
             .navigationBarTitle("首页", displayMode: .inline)

        }
        .toast(isShowing: $store.appState.goodList.isShowError,
               text: Text(store.appState.goodList.netWorkError?.errorDescription() ?? ""))
    }
}


struct SearchBar: View {
    @Binding var text: String

    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }, label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            })
                        }
                    }
            )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
            }

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""

                }, label: {
                    Text("取消")
                })
                    .padding(.trailing, 10)
            }
        }
    }
}

struct GoodList_Previews: PreviewProvider {
    static var previews: some View {
        GoodList().environmentObject(Store())
    }
}
