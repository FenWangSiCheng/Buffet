import Foundation

extension CartItem {
    var quantityText: String { quantity.formatted() }
    var soldText: String { "已售: \(product.sold.formatted())" }
}
