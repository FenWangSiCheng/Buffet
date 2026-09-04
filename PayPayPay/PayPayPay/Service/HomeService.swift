//
//  FindService.swift
//  SwiftModul
//
//  Created by wangsicheng on 2018/7/4.
//  Copyright © 2018年 fenrir-cd. All rights reserved.
//

import Foundation
import Combine
import Moya

@MainActor
protocol ProductRepository {
    func fetchProducts(page: Int) async throws -> [ProductInfoModel]
}

@MainActor
final class ProductRepositoryImpl: ProductRepository {
    private let network: Network
    init(network: Network = .instance) { self.network = network }
    func fetchProducts(page: Int) async throws -> [ProductInfoModel] {
        try await withCheckedThrowingContinuation { continuation in
            network.request(.getAllProducts(parameters: [APIConst.getAllProducts: page]))
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion { continuation.resume(throwing: error) }
                }, receiveValue: { products in continuation.resume(returning: products) })
                .store(in: &CancellableBox.shared.values)
        }
    }
}

@MainActor
private final class CancellableBox {
    static let shared = CancellableBox()
    var values = Set<AnyCancellable>()
}
