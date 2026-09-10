import XCTest
@testable import PayPayPay

final class UserDefaultsCartRepositoryTests: XCTestCase {
    @MainActor
    func testMigratesLegacyKeysAndPersistsAtomicSnapshot() async throws {
        let suite = "BuffetTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(2, forKey: "cart.count.one")
        defaults.set(true, forKey: "cart.selected.one")
        let cart = ManageCartUseCase(repository: UserDefaultsCartRepository(defaults: defaults))
        let products = [Product(id: "one")]
        let restored = await cart.restore(products: products)
        XCTAssertEqual(restored[0].quantity, 2)
        XCTAssertTrue(restored[0].isSelected)
        _ = await cart.removeSelected()
        let recreated = UserDefaultsCartRepository(defaults: defaults)
        let persisted = recreated.load(for: ["one"])
        XCTAssertEqual(persisted, Cart())
        XCTAssertNotNil(defaults.data(forKey: "cart.snapshot.v1"))
    }
}
