protocol CartRepository: Sendable {
    func load(for productIDs: [String]) async -> Cart
    func save(_ cart: Cart) async
}
