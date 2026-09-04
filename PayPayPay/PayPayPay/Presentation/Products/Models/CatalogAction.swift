enum CatalogAction {
    case loadProducts
    case increaseQuantity(productID: String)
    case decreaseQuantity(productID: String)
    case selectItem(productID: String)
    case deselectItem(productID: String)
    case selectAll
    case deselectAll
    case removeSelected
}
