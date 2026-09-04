//
//  ToastView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/11.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit
import SwiftUI

struct ToastView<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @State private var dismissTask: GCDDelayTask?

    let presenting: () -> Presenting

    let text: Text

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .blur(radius: self.isShowing ? 1 : 0)

                if isShowing {
                    VStack {
                        self.text
                    }
                    .frame(width: geometry.size.width / 2,
                           height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .transition(.slide)
                    .onAppear {
                        cancel(dismissTask)
                        dismissTask = delay(2) { isShowing = false }
                    }
                    .onDisappear {
                        cancel(dismissTask)
                        dismissTask = nil
                    }
                }

            }

        }

    }

}

extension View {

    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        ToastView(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}
