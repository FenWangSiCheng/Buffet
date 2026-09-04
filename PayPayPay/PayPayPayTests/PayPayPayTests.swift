import XCTest
@testable import PayPayPay

final class PayPayPayTests: XCTestCase {
    @MainActor
    func testGoodsFailureFinishesLoading() {
        var state = AppState()
        state.goodList.loadingGoods = true

        let (updated, command) = Store.reduce(
            state: state,
            action: .loadGoodssDone(result: .failure(.notReachedServer))
        )

        XCTAssertFalse(updated.goodList.loadingGoods)
        XCTAssertTrue(updated.goodList.isShowError)
        XCTAssertEqual(updated.goodList.netWorkError, .notReachedServer)
        XCTAssertNil(command)
    }

    @MainActor
    func testDelayRunsOnMainActor() async {
        let completed = expectation(description: "Delayed callback")
        _ = delay(0.01) {
            MainActor.assertIsolated()
            completed.fulfill()
        }
        await fulfillment(of: [completed], timeout: 1)
    }

    @MainActor
    func testCancelledDelayDoesNotRun() async {
        let completed = expectation(description: "Cancelled callback")
        completed.isInverted = true
        let task = delay(0.01) {
            completed.fulfill()
        }
        cancel(task)
        cancel(task)
        await fulfillment(of: [completed], timeout: 0.1)
    }
}
