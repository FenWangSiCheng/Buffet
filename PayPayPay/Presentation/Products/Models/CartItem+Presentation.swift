import Foundation

extension CartItem {
    var nameText: String { product.name }
    var quantityText: String { "\(quantity)" }
    var soldText: String { "已售: \(product.sold)" }
    var originalPriceText: String { product.originalPrice?.formattedPrice ?? "" }
    var priceText: String { product.price.formattedPrice }
    var imageURL: URL? { product.imageURL }
}
