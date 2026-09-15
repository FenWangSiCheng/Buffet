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
        guard !id.isEmpty, let price else {
            throw RepositoryError.invalidData
        }
        let imageURL = image.map { imageBaseURL.appendingPathComponent($0) }
        let domainPrice = try nonNegativeMoney(price)
        let domainOriginalPrice = try originalPrice.map { try nonNegativeMoney($0) }
        return Product(id: id, name: name ?? "", imageURL: imageURL,
                       originalPrice: domainOriginalPrice, price: domainPrice,
                       sold: sold ?? 0, barcode: barcode)
    }

    /// A price is valid only when it parses as a non-negative decimal amount.
    private func nonNegativeMoney(_ value: String) throws -> Money {
        guard let money = Money(decimalString: value), money >= .zero else {
            throw RepositoryError.invalidData
        }
        return money
    }
}
