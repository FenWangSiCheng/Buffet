//
//  Toast.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/11.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit
import SwiftUI

struct Toast<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool

    let presenting: () -> Presenting

    let text: Text

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    self.text
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)

            }

        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              self.isShowing = false
            }
        }

    }

}

extension View {

    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}
