//
//  Const.swift
//  SwiftModul
//
//  Created by fenrir-cd on 2018/7/25.
//  Copyright © 2018年 fenrir-cd. All rights reserved.
//

import UIKit

let goodSelectedKey = "goodSelectedKey"

func printLog<T>(_ message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line) {
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

@MainActor let kScreenW = UIScreen.main.bounds.width
@MainActor let kScreenH = UIScreen.main.bounds.height

@MainActor let iphoneXR = kScreenH == 896 ? true : false
@MainActor let iphoneX =  kScreenH == 812 ? true : false
@MainActor let iphone8P = kScreenH == 736 ? true : false
@MainActor let iphone8 = kScreenH == 667 ? true : false
@MainActor let iphone5 = kScreenH == 568 ? true : false
@MainActor let iphone4 = kScreenH == 480 ? true : false

@MainActor let navigationBarHeight: CGFloat = iphoneX || iphoneXR ? 88 : 64
@MainActor let tabbarHeight: CGFloat = iphoneX || iphoneXR ? 83 : 49
@MainActor let statusBarHeight: CGFloat = iphoneX || iphoneXR ? 44 : 20

struct AssetsImageNames {

    static let placeHodelName = "tabbar_download_h"
}

public enum DateMode: Int {
    case text
    case digit

    var format: String {
        return self == .text ? "E, dd MMMM" : "EEEEE, MM/dd"
    }
}

public enum TemperatureMode: Int {
    case celsius
    case fahrenheit
}

struct APIConst {

    static let basePath = "https://store/api"
    static let getAllProducts = "/goods"

}

// MARK: - gcd delay
typealias GCDDelayTask = @MainActor (_ cancel: Bool) -> Void

@MainActor
func delay(_ time: TimeInterval, task: @escaping @MainActor () -> Void) -> GCDDelayTask? {
    var pendingTask: (@MainActor () -> Void)? = task
    let delayedTask: GCDDelayTask = { cancel in
        let action = pendingTask
        pendingTask = nil
        if !cancel {
            action?()
        }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        delayedTask(false)
    }
    return delayedTask
}

@MainActor
func cancel(_ task: GCDDelayTask?) {
    task?(true)
}

// MARK: - operator
infix operator ???: NilCoalescingPrecedence

public func ???<T> (optional: T?, defaultValue: @autoclosure () -> String)
    -> String {
    switch optional {
    case let value?:
        return String(describing: value)
    case nil:
        return defaultValue()
    }
}


let accessToken = "accessToken"
let appIsLogin = "appIsLogin"
let appProfile = "appProfile"

