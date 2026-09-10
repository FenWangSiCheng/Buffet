import Foundation

/// Catalog data independent of transport, storage and presentation formatting.
struct Product: Equatable, Identifiable, Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let originalPrice: Money?
    let price: Money
    let sold: Int
    let barcode: String?

    init(id: String, name: String = "", imageURL: URL? = nil,
         originalPrice: Money? = nil, price: Money = .zero,
         sold: Int = 0, barcode: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.originalPrice = originalPrice
        self.price = price
        self.sold = sold
        self.barcode = barcode
    }
}
