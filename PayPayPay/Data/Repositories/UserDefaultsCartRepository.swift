import Foundation

@MainActor
final class UserDefaultsCartRepository: CartRepository {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) { self.defaults = defaults }

    // Keep the original keys so existing installations retain their cart.
    func count(for productID: String) -> Int { defaults.integer(forKey: "cart.count.\(productID)") }
    func setCount(_ count: Int, for productID: String) {
        defaults.set(max(0, count), forKey: "cart.count.\(productID)")
    }
    func isSelected(for productID: String) -> Bool { defaults.bool(forKey: "cart.selected.\(productID)") }
    func setSelected(_ selected: Bool, for productID: String) {
        defaults.set(selected, forKey: "cart.selected.\(productID)")
    }
}
