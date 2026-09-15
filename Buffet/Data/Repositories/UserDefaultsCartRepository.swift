import Foundation

@MainActor
final class UserDefaultsCartRepository: CartRepository {
    private struct StoredEntry: Codable {
        let quantity: Int
        let isSelected: Bool
    }

    private let defaults: UserDefaults
    private let snapshotKey = "cart.snapshot.v1"

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load(for productIDs: [String]) -> Cart {
        if let data = defaults.data(forKey: snapshotKey),
           let stored = try? JSONDecoder().decode([String: StoredEntry].self, from: data) {
            return makeCart(from: stored)
        }

        // No snapshot yet: migrate the per-product keys written by the first version, then keep the snapshot.
        let legacyEntries: [String: StoredEntry] = Dictionary(
            uniqueKeysWithValues: productIDs.compactMap { productID -> (String, StoredEntry)? in
                let quantity = max(0, defaults.integer(forKey: "cart.count.\(productID)"))
                guard quantity > 0 else { return nil }
                return (productID, StoredEntry(
                    quantity: quantity,
                    isSelected: defaults.bool(forKey: "cart.selected.\(productID)")
                ))
            }
        )
        let cart = makeCart(from: legacyEntries)
        saveSnapshot(cart)
        return cart
    }

    func save(_ cart: Cart) {
        saveSnapshot(cart)
    }

    private func makeCart(from stored: [String: StoredEntry]) -> Cart {
        Cart(entries: stored.mapValues {
            Cart.Entry(quantity: $0.quantity, isSelected: $0.isSelected)
        })
    }

    private func saveSnapshot(_ cart: Cart) {
        let stored = cart.entries.mapValues {
            StoredEntry(quantity: $0.quantity, isSelected: $0.isSelected)
        }
        guard let data = try? JSONEncoder().encode(stored) else { return }
        defaults.set(data, forKey: snapshotKey)
    }
}
