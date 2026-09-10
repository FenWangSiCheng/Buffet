//
//  SceneDelegate.swift
//  PayPayPay
//
//  Created by wangsicheng on 2020/8/18.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let catalogViewModel = AppContainer.makeCatalogViewModel()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let contentView = MainTabView().environmentObject(catalogViewModel)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        catalogViewModel.cancelLoading()
    }
}
