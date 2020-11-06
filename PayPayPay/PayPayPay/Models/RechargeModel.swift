//
//  RechargeModel.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/14.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import Foundation

struct RechargeModel: Codable, Identifiable {
    var id = UUID()
    var state: Int?
    var money: String?
    var createTime: String?
    var modifyTime: String
    
}
