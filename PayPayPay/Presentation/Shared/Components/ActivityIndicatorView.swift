//
//  ActivityIndicatorView.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/14.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: View {
    let isAnimating: Bool

    var body: some View {
        if isAnimating {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        }
    }
}
