//
//  ServiceManager.swift
//  SwiftModul
//
//  Created by wangsicheng on 2018/7/4.
//  Copyright © 2018年 fenrir-cd. All rights reserved.
//

import Foundation
import Moya

@MainActor
final class ServiceManager {
    static let shared = ServiceManager()
    private init() {}
}
