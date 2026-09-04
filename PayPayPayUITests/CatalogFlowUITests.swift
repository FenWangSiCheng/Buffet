import XCTest

final class CatalogFlowUITests: XCTestCase {
    @MainActor
    func testProductSearchAndCartNavigation() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let riceCrackers = app.staticTexts["旺旺 仙贝 零食 膨化食品 饼干糕点 888g"]
        XCTAssertTrue(riceCrackers.waitForExistence(timeout: 10))
        let search = app.textFields.firstMatch
        search.tap()
        search.typeText("雪饼")
        XCTAssertTrue(app.staticTexts["旺旺 雪饼 零食 膨化食品 饼干糕点 888g"].exists)
        XCTAssertFalse(riceCrackers.exists)

        app.buttons["取消"].tap()
        XCTAssertTrue(riceCrackers.exists)
        app.tabBars.buttons["购物车"].tap()
        XCTAssertTrue(app.navigationBars["商品"].waitForExistence(timeout: 3))
        app.tabBars.buttons["首页"].tap()
        XCTAssertTrue(riceCrackers.waitForExistence(timeout: 10))
    }
}
