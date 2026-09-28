/// Local cart storage. Reads and writes finish in the same isolation domain as cart mutations.
@MainActor
protocol CartRepository: Sendable {
    func load(for productIDs: [String]) -> Cart
    func save(_ cart: Cart)
}
