//
//  Double+Currency.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/31.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import Foundation

extension Double {
    var formattedPrice: String { formatted(.number.precision(.fractionLength(2))) }
}
