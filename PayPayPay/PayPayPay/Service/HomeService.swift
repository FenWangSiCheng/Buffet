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

class HomeService {
    
    let networking: Network!
    
    init(networking: Network) {
        self.networking = networking
    }

    func getAllProducts(page: Int) -> AnyPublisher<[ProductInfoModel], NetworkError> {
        let parameters = [APIConst.getAllProducts: page]
        return networking
            .request(.getAllProducts(parameters: parameters))
    }
}
