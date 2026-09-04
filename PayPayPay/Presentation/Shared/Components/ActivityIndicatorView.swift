//
//  ActivityIndicatorView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/14.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    let isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
