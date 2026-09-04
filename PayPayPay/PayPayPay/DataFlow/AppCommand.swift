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

@MainActor
protocol AppCommand {
    func execute(in store: Store)
}

struct LoadGoodsCommand: AppCommand {
    let repository: ProductRepository

    func execute(in store: Store) {
        _Concurrency.Task { @MainActor in
            do {
                store.dispatch(.loadGoodssDone(result: .success(try await repository.fetchProducts(page: 0))))
            } catch let error as NetworkError {
                store.dispatch(.loadGoodssDone(result: .failure(error)))
            } catch {
                store.dispatch(.loadGoodssDone(result: .failure(.unknown)))
            }
        }
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
