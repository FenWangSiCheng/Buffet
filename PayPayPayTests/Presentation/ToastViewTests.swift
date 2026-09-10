import SwiftUI
import XCTest
@testable import PayPayPay

final class ToastViewTests: XCTestCase {
    @MainActor
    func testToastDismissesItselfAfterAppearing() async throws {
        let dismissed = expectation(description: "Toast dismissed itself")
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIHostingController(rootView: ToastHostView {
            dismissed.fulfill()
        })
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }

        await fulfillment(of: [dismissed], timeout: 5)
    }
}

private struct ToastHostView: View {
    let onDismiss: () -> Void

    var body: some View {
        Color.clear.toast(message: "请求失败", onDismiss: onDismiss)
    }
}
