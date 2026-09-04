import XCTest
@testable import PayPayPay

final class UserDefaultsCartRepositoryTests: XCTestCase {
    @MainActor
    func testExistingKeysSurviveRepositoryRecreationAndDeletion() throws {
        let suite = "BuffetTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(2, forKey: "cart.count.one")
        defaults.set(true, forKey: "cart.selected.one")
        let cart = ManageCartUseCase(repository: UserDefaultsCartRepository(defaults: defaults))
        let products = [Product(id: "one")]
        let restored = cart.restore(products: products)
        XCTAssertEqual(restored[0].quantity, 2)
        XCTAssertTrue(restored[0].isSelected)
        _ = cart.removeSelected(from: restored)
        let recreated = UserDefaultsCartRepository(defaults: defaults)
        XCTAssertEqual(recreated.count(for: "one"), 0)
        XCTAssertFalse(recreated.isSelected(for: "one"))
    }
}
