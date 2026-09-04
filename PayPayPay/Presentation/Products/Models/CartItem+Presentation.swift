import Foundation

extension CartItem {
    var nameText: String { product.name ?? "" }
    var quantityText: String { "\(quantity)" }
    var soldText: String { "已售: \(product.sold ?? 0)" }
    var originalPriceText: String { "￥\(product.originalPrice ?? "")" }
    var priceText: String { "￥\(product.price ?? "")" }
    var imageURL: URL? { product.imageURL }
}
