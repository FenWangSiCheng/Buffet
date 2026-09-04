//
//  MySettingService.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/9.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit
import Combine
import Moya

@MainActor
protocol CartRepository {
    func count(for productID: String) -> Int
    func setCount(_ count: Int, for productID: String)
    func isSelected(for productID: String) -> Bool
    func setSelected(_ selected: Bool, for productID: String)
}

@MainActor
final class CartRepositoryImpl: CartRepository {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    func count(for productID: String) -> Int { defaults.integer(forKey: "cart.count.\(productID)") }
    func setCount(_ count: Int, for productID: String) { defaults.set(max(0, count), forKey: "cart.count.\(productID)") }
    func isSelected(for productID: String) -> Bool { defaults.bool(forKey: "cart.selected.\(productID)") }
    func setSelected(_ selected: Bool, for productID: String) { defaults.set(selected, forKey: "cart.selected.\(productID)") }
}
