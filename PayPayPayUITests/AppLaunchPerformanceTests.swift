//
//  AppLaunchPerformanceTests.swift
//  PayPayPayUITests
//
//  Created by wangsicheng on 2020/8/18.
//  Copyright © 2020 wangsicheng. All rights reserved.
//

import XCTest

final class AppLaunchPerformanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
