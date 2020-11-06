//
//  AppCommand.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/19.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import Moya

protocol AppCommand {
    func execute(in store: Store)
}

struct LoadGoodsCommand: AppCommand {

    func execute(in store: Store) {
        let token = SubscriptionToken()
        ServiceManager.shared.homeService.getAllProducts(page: 0)
            .sink(receiveCompletion: { (complete) in
                if case .failure(let error) = complete {
                    store.dispatch(.loadGoodssDone(result: .failure(error)))
                }
                token.unseal()
            }, receiveValue: { (value) in
                store.dispatch(.loadGoodssDone(result: .success(value)))
            })
            .seal(in: token)
    }
}


class SubscriptionToken {
    var cancellable: AnyCancellable?
    func unseal() { cancellable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}
