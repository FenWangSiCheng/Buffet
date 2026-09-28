import XCTest
@testable import Buffet

final class ManageCartUseCaseTests: XCTestCase {
    @MainActor
    func testQuantityCannotBecomeNegativeAndZeroClearsSelection() {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        let product = Product(id: "one")
        repository.save(Cart(entries: ["one": Cart.Entry(quantity: 1, isSelected: true)]))
        _ = useCase.restore(products: [product])
        var items = useCase.changeQuantity(of: "one", by: -1)
        items = useCase.changeQuantity(of: "one", by: -1)
        XCTAssertEqual(items[0].quantity, 0)
        XCTAssertFalse(items[0].isSelected)
        XCTAssertEqual(repository.cart, Cart())
    }

    @MainActor
    func testSelectAllOnlySelectsProductsInCart() {
        let useCase = ManageCartUseCase(repository: InMemoryCartRepository())
        let products = [Product(id: "one"), Product(id: "two")]
        _ = useCase.restore(products: products)
        _ = useCase.changeQuantity(of: "one", by: 2)
        let selected = useCase.select(true)
        XCTAssertTrue(selected[0].isSelected)
        XCTAssertFalse(selected[1].isSelected)
        let deselected = useCase.select(false)
        XCTAssertTrue(deselected.allSatisfy { !$0.isSelected })
    }

    @MainActor
    func testRemoveSelectedPersistsAtomicSnapshot() {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        let products = [Product(id: "one"), Product(id: "two")]
        _ = useCase.restore(products: products)
        _ = useCase.changeQuantity(of: "one", by: 2)
        _ = useCase.changeQuantity(of: "two", by: 1)
        _ = useCase.select(true, productID: "one")
        let removed = useCase.removeSelected()
        let restored = ManageCartUseCase(repository: repository).restore(products: products)
        XCTAssertEqual(removed, restored)
        XCTAssertEqual(removed.map(\.quantity), [0, 1])
        XCTAssertEqual(repository.cart.entries, [
            "two": Cart.Entry(quantity: 1, isSelected: false)
        ])
    }

    @MainActor
    func testCartNormalizesStaleSelectionForEmptyEntry() {
        let repository = InMemoryCartRepository(cart: Cart(entries: [
            "one": Cart.Entry(quantity: 0, isSelected: true)
        ]))
        let items = ManageCartUseCase(repository: repository).restore(products: [Product(id: "one")])
        XCTAssertFalse(items[0].isSelected)
    }

    @MainActor
    func testCatalogRefreshPreservesSessionEditsWithoutReloadingStorage() {
        let repository = InMemoryCartRepository(cart: Cart(entries: [
            "one": Cart.Entry(quantity: 2, isSelected: true)
        ]))
        let useCase = ManageCartUseCase(repository: repository)
        _ = useCase.restore(products: [Product(id: "one")])
        _ = useCase.changeQuantity(of: "one", by: 1)
        // A stale external snapshot must not replace the authoritative session cart.
        repository.save(Cart())
        let items = useCase.restore(products: [Product(id: "one", name: "Updated")])
        XCTAssertEqual(items[0].quantity, 3)
        XCTAssertTrue(items[0].isSelected)
        XCTAssertEqual(items[0].product.name, "Updated")
        XCTAssertEqual(repository.loadCount, 1)
    }

    @MainActor
    func testCommandsBeforeRestorationDoNotOverwriteStorage() {
        let saved = Cart(entries: ["one": Cart.Entry(quantity: 2, isSelected: true)])
        let repository = InMemoryCartRepository(cart: saved)
        let useCase = ManageCartUseCase(repository: repository)
        _ = useCase.changeQuantity(of: "one", by: 1)
        _ = useCase.removeSelected()
        XCTAssertEqual(repository.cart, saved)
        let restored = useCase.restore(products: [Product(id: "one")])
        XCTAssertEqual(restored[0].quantity, 2)
    }

    func testSubtotalUsesDecimalArithmetic() {
        let product = Product(id: "one", price: Money(decimalString: "0.1")!)
        let item = CartItem(product: product, quantity: 3)
        XCTAssertEqual(item.subtotal, Money(decimalString: "0.3"))
    }
}
