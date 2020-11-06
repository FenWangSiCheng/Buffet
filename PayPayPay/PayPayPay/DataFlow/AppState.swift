//
//  AppState.swift
//  PokeMaster
//
//  Created by wangsicheng on 2019/09/04.
//  Copyright © 2019 wangsicheng. All rights reserved.
//

import Combine
import Foundation

struct AppState {
    var goodList = GoodList()
    var userSetting = UserSetting()
    var rechargeRecord = RechargeRecord()
}

extension AppState {
    struct GoodList {
        var netWorkError: NetworkError?
        var isShowError: Bool = false
        var goods: [ProductInfoModel]?
        var loadingGoods = false
        var badgeNumber: Int {
           return self.goods?.filter { $0.shopCarCount > 0 }.count ?? 0
        }
        var haveSelected: Bool {
            return self.goods?.filter { $0.isSelected }.count ?? 0 > 0
        }

        var totlaPrice: Double {
            return self.goods!.reduce(0.0, { (result, model) -> Double in
                var result = result
                if model.isSelected {
                    result += (Double(model.price ?? "0") ?? 0) * Double(model.shopCarCount)
                }
                return result
            })
        }

        var isAllSelected: Bool {
            let selectedCount = self.goods?.filter { $0.isSelected }.count ?? 0
            return selectedCount == self.badgeNumber
        }
    }
}

extension AppState {

    struct UserSetting {
        var netWorkError: NetworkError?
        var isShowError: Bool = false
        var loadingUserInfo = false
        var profile: ProfileModel? {
            get {
                UserDefaults.standard.object(ProfileModel.self, with: appProfile)
            }
            set {
                UserDefaults.standard.set(object: newValue, forKey: appProfile)
            }
        }
    }
}

extension AppState {
    struct RechargeRecord {
        var recharges: [RechargeModel]?
        var loadingRecharges: Bool = false
        var isShowError: Bool = false
        var netWorkError: NetworkError?
    }
}


