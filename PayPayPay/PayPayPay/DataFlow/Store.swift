//
//  Store.swift
//  PokeMaster
//
//  Created by wangsicheng on 2019/09/03.
//  Copyright © 2019 wangsicheng. All rights reserved.
//
import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()

    private var disposeBag = Set<AnyCancellable>()

    init() {
    }

    func dispatch(_ action: AppAction) {
        #if DEBUG
        print("[ACTION]: \(action)")
        #endif
        let result = Store.reduce(state: appState, action: action)
        appState = result.0
        if let command = result.1 {
            #if DEBUG
            print("[COMMAND]: \(command)")
            #endif
            command.execute(in: self)
        }
    }

    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand?

        switch action {
        case .loadGoods:
            if appState.goodList.loadingGoods {
                break
            }
            appState.goodList.loadingGoods = true
            appCommand = LoadGoodsCommand()
        case .loadGoodssDone(result: let result):
            appState.goodList.loadingGoods = false
            switch result {
            case .success(let models):
                appState.goodList.goods = models
                appState.goodList.netWorkError = nil
                appState.goodList.isShowError = false
            case .failure(let error):
                appState.goodList.netWorkError = error
                appState.goodList.isShowError = true
            }
        case .addShopCar(let model):
            if let indices = appState.goodList.goods?.indices(of: model) {
                indices.forEach { (index) in
                    appState.goodList.goods?[index].shopCarCount += 1
                }
            }
        case .subShopCar(let model):
            if let indices = appState.goodList.goods?.indices(of: model) {
                indices.forEach { (index) in
                    appState.goodList.goods?[index].shopCarCount -= 1
                }
            }
        case .selectedGood(let model):

            if let indices = appState.goodList.goods?.indices(of: model) {
                indices.forEach { (index) in
                    appState.goodList.goods?[index].isSelected = true
                }
            }

        case .canceledGood(let model):
            if let indices = appState.goodList.goods?.indices(of: model) {
                indices.forEach { (index) in
                    appState.goodList.goods?[index].isSelected = false
                }
            }

        case .selectedAllGoods:
            if appState.goodList.goods == nil {
                break
            }
            let models =  appState.goodList.goods!.map { (model) -> ProductInfoModel in
                var newModel = model
                if model.shopCarCount > 0 {
                    newModel.isSelected = true
                }
                return newModel
            }
            appState.goodList.goods = models
        case .canceledAllGoods:
            if appState.goodList.goods == nil {
                break
            }
            let models =  appState.goodList.goods!.map { (model) -> ProductInfoModel in
                var newModel = model
                if model.shopCarCount > 0 {
                    newModel.isSelected = false
                }
                return newModel
            }
            appState.goodList.goods = models
        case .deletedSelectGood:
            if appState.goodList.goods == nil {
                break
            }
            let models =  appState.goodList.goods!.map { (model) -> ProductInfoModel in
                var newModel = model
                if newModel.isSelected && newModel.shopCarCount > 0 {
                    newModel.shopCarCount = 0
                    newModel.isSelected = false
                }
                return newModel
            }
            appState.goodList.goods = models
        case .wxworkrequest:
            break
        case .loadUserInfo(code: _):
            if appState.userSetting.loadingUserInfo  {
                break
            }
            appState.userSetting.loadingUserInfo = true
        case .loadUserInfoDone(result: let result):
            appState.userSetting.loadingUserInfo = false
            switch result {
            case .success(let model):
                appState.userSetting.profile = model
                appState.userSetting.netWorkError = nil
                appState.userSetting.isShowError = false
            case .failure(let error):
                appState.userSetting.netWorkError = error
                appState.userSetting.isShowError = true
            }

        case .loadRecharge:
            if appState.goodList.loadingGoods {
                break
            }
            appState.goodList.loadingGoods = true
            appCommand = LoadGoodsCommand()
        case .loadeRechargeDone(result: let result):
            appState.goodList.loadingGoods = false
            switch result {
            case .success( _):
                break
//                appState.goodList.goods = models
////                appState.goodList.netWorkError = nil
////                appState.goodList.isShowError = false
            case .failure(let error):
                appState.goodList.netWorkError = error
                appState.goodList.isShowError = true
            }
        }
        return (appState, appCommand)
    }

}

