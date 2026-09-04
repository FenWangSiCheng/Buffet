import Foundation

/// Catalog data independent of transport, storage and presentation formatting.
struct Product: Equatable, Identifiable, Sendable {
    let id: String
    var name: String?
    var imageURL: URL?
    var originalPrice: String?
    var price: String?
    var sold: Int?
    var barcode: String?
}
