//
//  AppAction.swift
//  PokeMaster
//
//  Created by wangsicheng on 2019/09/05.
//  Copyright © 2019 wangsicheng. All rights reserved.
//

import Foundation
import Moya

enum AppAction {
    
    case loadGoods
    case loadGoodssDone(result: Result<[ProductInfoModel], NetworkError>)
    case addShopCar(model: ProductInfoModel)
    case subShopCar(model: ProductInfoModel)

    case selectedGood(model: ProductInfoModel)
    case canceledGood(model: ProductInfoModel)
    case selectedAllGoods
    case canceledAllGoods
    case deletedSelectGood

    case wxworkrequest
    case loadUserInfo(code: String)
    case loadUserInfoDone(result: Result<ProfileModel, NetworkError>)

    case loadRecharge
    case loadeRechargeDone(result: Result<RechargeModel, NetworkError>)
}
