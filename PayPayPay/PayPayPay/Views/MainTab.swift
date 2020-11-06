//
//  MainTab.swift
//  PokeMaster
//
//  Created by Wang Wei on 2019/09/02.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI

struct MainTab: View {
    @EnvironmentObject var store: Store
    private var badgePosition: CGFloat = 2
    private var tabsCount: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
               TabView {
                    GoodList().tabItem {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("首页")
                    }
                   ShopCar().tabItem {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("购物车")
                    }
                }
                .accentColor(.orange)

                ZStack {
                    Circle()
                        .foregroundColor(.red)

                    Text("\(self.store.appState.goodList.badgeNumber)")
                        .foregroundColor(.white)
                        .font(Font.system(size: 12))
                }
                .frame(width: 20, height: 20)
                .offset(x: ( ( 2 * self.badgePosition) - 1 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ), y: -30)
                .opacity(self.store.appState.goodList.badgeNumber == 0 ? 0 : 1)
            }
        }
    }

}

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            MainTab()
                .environment(\.colorScheme, .light)
                .previewDevice(PreviewDevice(rawValue: "iPhone X"))
                .environmentObject(Store())
            MainTab()
                .environment(\.colorScheme, .dark)
                .previewDevice(PreviewDevice(rawValue: "iPhone X"))
                .environmentObject(Store())
            MainTab()
                .environment(\.colorScheme, .light)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .environmentObject(Store())
        }

    }
}
