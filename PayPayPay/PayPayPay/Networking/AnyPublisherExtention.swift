//
//  SingleNetworkExtention.swift
//  SwiftModul
//
//  Created by wangsicheng on 2018/7/4.
//  Copyright © 2018年 fenrir-cd. All rights reserved.
//

import UIKit
import Moya
import Combine

extension AnyPublisher where Output == Response, Failure == MoyaError {

    public func parse<T: Decodable>(_ type: T.Type) -> AnyPublisher<T, MoyaError> {
        return map(T.self)
    }

    public func cacheData(_ target: NetworkTarget) -> AnyPublisher<Output, MoyaError> {

        return self.map { (response) -> Output in
            UserDefaults.standard[target.baseURL.absoluteString + target.path] = response.data
            return response
        }.catch { (error) -> AnyPublisher<Output, MoyaError> in
           return  Future { (promise) in
                let data = UserDefaults.standard.object(Data.self, with: target.baseURL.absoluteString + target.path)
                if data == nil {
                    promise(.failure(error))
                } else {
                    promise(.success(Response(statusCode: 200, data: data!)))
                }
            }.eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    
    }
}
