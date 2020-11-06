//
//  DoubleExtensions.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/31.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import Foundation

extension Double {

    public func stringToPrice() -> String {
        return String(format: "%.02f", self)
    }
}
