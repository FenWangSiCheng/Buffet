import XCTest
@testable import PayPayPay

final class ManageCartUseCaseTests: XCTestCase {
    @MainActor
    func testQuantityCannotBecomeNegativeAndZeroClearsSelection() {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        var items = [CartItem(product: Product(id: "one"), quantity: 1, isSelected: true)]
        items = useCase.changeQuantity(of: "one", by: -1, in: items)
        items = useCase.changeQuantity(of: "one", by: -1, in: items)
        XCTAssertEqual(items[0].quantity, 0)
        XCTAssertFalse(items[0].isSelected)
        XCTAssertEqual(repository.count(for: "one"), 0)
        XCTAssertFalse(repository.isSelected(for: "one"))
    }

    @MainActor
    func testSelectAllOnlySelectsProductsInCart() {
        let useCase = ManageCartUseCase(repository: InMemoryCartRepository())
        let items = [CartItem(product: Product(id: "one"), quantity: 2),
                     CartItem(product: Product(id: "two"))]
        let selected = useCase.select(true, in: items)
        XCTAssertTrue(selected[0].isSelected)
        XCTAssertFalse(selected[1].isSelected)
        XCTAssertTrue(useCase.select(false, in: selected).allSatisfy { !$0.isSelected })
    }

    @MainActor
    func testRemoveSelectedPersistsBothQuantityAndSelection() {
        let repository = InMemoryCartRepository()
        let useCase = ManageCartUseCase(repository: repository)
        let products = [Product(id: "one"), Product(id: "two")]
        var items = useCase.restore(products: products)
        items = useCase.changeQuantity(of: "one", by: 2, in: items)
        items = useCase.changeQuantity(of: "two", by: 1, in: items)
        items = useCase.select(true, productID: "one", in: items)
        let removed = useCase.removeSelected(from: items)
        XCTAssertEqual(removed, useCase.restore(products: products))
        XCTAssertEqual(removed.map(\.quantity), [0, 1])
        XCTAssertFalse(repository.isSelected(for: "one"))
    }

    @MainActor
    func testRestoreIgnoresStaleSelectionForEmptyCart() {
        let repository = InMemoryCartRepository()
        repository.selections["one"] = true
        let items = ManageCartUseCase(repository: repository).restore(products: [Product(id: "one")])
        XCTAssertFalse(items[0].isSelected)
    }
}
