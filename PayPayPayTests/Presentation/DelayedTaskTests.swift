import Combine
import SwiftUI
import XCTest
@testable import PayPayPay

final class DelayedTaskTests: XCTestCase {
    @MainActor
    func testToastShownAfterPageAppearsStillDismisses() async throws {
        let state = ToastTestState()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: ToastTestView(state: state))
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }

        // Let the original page-appearance timer expire before presenting an error.
        try await Task.sleep(nanoseconds: 2_200_000_000)
        state.isShowing = true
        let dismissed = expectation(description: "Late error toast dismissed")
        let subscription = state.$isShowing.dropFirst().filter { !$0 }.prefix(1)
            .sink { _ in dismissed.fulfill() }
        await fulfillment(of: [dismissed], timeout: 4)
        withExtendedLifetime(subscription) {}
        XCTAssertFalse(state.isShowing)
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

@MainActor
private final class ToastTestState: ObservableObject {
    @Published var isShowing = false
}

private struct ToastTestView: View {
    @ObservedObject var state: ToastTestState

    var body: some View {
        Text("Catalog").toast(isShowing: $state.isShowing, text: Text("Request failed"))
    }
}
