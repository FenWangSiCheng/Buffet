import Foundation

/// Backend field names and image path construction stay in the data layer.
struct ProductDTO: Decodable, Sendable {
    let id: String
    let name: String?
    let image: String?
    let originalPrice: String?
    let price: String?
    let sold: Int?
    let barcode: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, price, sold, barcode
        case originalPrice = "original_price"
    }

    func toDomain(imageBaseURL: URL) throws -> Product {
        guard !id.isEmpty else { throw RepositoryError.incorrectDataReturned }
        return Product(id: id, name: name,
                       imageURL: image.map { imageBaseURL.appendingPathComponent($0) },
                       originalPrice: originalPrice, price: price, sold: sold, barcode: barcode)
    }
}
