//
//  ProfileModel.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/9/9.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit

struct ProfileModel: Codable {

    var name: String?
    var email: String?
    var avatar: String?
    var balance: String?
}

extension ProfileModel: ProfileInfoProtocal {
    var nameStr: String? {
        self.name
    }

    var emailStr: String? {
        self.email
    }

    var imageUrl: URL? {
        URL(string: self.avatar!)
    }

    var balanceStr: String? {
        if let balance = self.balance {
            return "账户余额: " + balance
        } else {
            return ""
        }
    }


}

protocol ProfileInfoProtocal {

    var nameStr: String? { get }
    var emailStr: String? { get }
    var imageUrl: URL? { get }
    var balanceStr: String? { get }
}
