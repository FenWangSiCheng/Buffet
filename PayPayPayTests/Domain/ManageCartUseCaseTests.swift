import XCTest
@testable import PayPayPay

final class ManageCartUseCaseTests: XCTestCase {
    @MainActor
    func testQuantityCannotBecomeNegativeAndZeroClearsSelection() async {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        let product = Product(id: "one")
        repository.save(Cart(entries: ["one": Cart.Entry(quantity: 1, isSelected: true)]))
        _ = await useCase.restore(products: [product])
        var items = await useCase.changeQuantity(of: "one", by: -1)
        items = await useCase.changeQuantity(of: "one", by: -1)
        XCTAssertEqual(items[0].quantity, 0)
        XCTAssertFalse(items[0].isSelected)
        XCTAssertEqual(repository.cart, Cart())
    }

    @MainActor
    func testSelectAllOnlySelectsProductsInCart() async {
        let useCase = ManageCartUseCase(repository: InMemoryCartRepository())
        let products = [Product(id: "one"), Product(id: "two")]
        _ = await useCase.restore(products: products)
        _ = await useCase.changeQuantity(of: "one", by: 2)
        let selected = await useCase.select(true)
        XCTAssertTrue(selected[0].isSelected)
        XCTAssertFalse(selected[1].isSelected)
        let deselected = await useCase.select(false)
        XCTAssertTrue(deselected.allSatisfy { !$0.isSelected })
    }

    @MainActor
    func testRemoveSelectedPersistsAtomicSnapshot() async {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        let products = [Product(id: "one"), Product(id: "two")]
        _ = await useCase.restore(products: products)
        _ = await useCase.changeQuantity(of: "one", by: 2)
        _ = await useCase.changeQuantity(of: "two", by: 1)
        _ = await useCase.select(true, productID: "one")
        let removed = await useCase.removeSelected()
        let restored = await useCase.restore(products: products)
        XCTAssertEqual(removed, restored)
        XCTAssertEqual(removed.map(\.quantity), [0, 1])
        XCTAssertEqual(repository.cart.entries, [
            "two": Cart.Entry(quantity: 1, isSelected: false)
        ])
    }

    @MainActor
    func testCartNormalizesStaleSelectionForEmptyEntry() async {
        let repository = InMemoryCartRepository(cart: Cart(entries: [
            "one": Cart.Entry(quantity: 0, isSelected: true)
        ]))
        let items = await ManageCartUseCase(repository: repository).restore(products: [Product(id: "one")])
        XCTAssertFalse(items[0].isSelected)
    }

    func testSubtotalUsesDecimalArithmetic() {
        let product = Product(id: "one", price: Money(decimalString: "0.1")!)
        let item = CartItem(product: product, quantity: 3)
        XCTAssertEqual(item.subtotal, Money(decimalString: "0.3"))
    }
}
