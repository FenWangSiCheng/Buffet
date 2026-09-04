import Foundation

struct CartItem: Equatable, Identifiable, Sendable {
    let product: Product
    var quantity: Int = 0
    var isSelected: Bool = false

    var id: String { product.id }
    var subtotal: Double { (Double(product.price ?? "0") ?? 0) * Double(quantity) }
}
