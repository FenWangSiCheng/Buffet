@MainActor
protocol CartRepository {
    func count(for productID: String) -> Int
    func setCount(_ count: Int, for productID: String)
    func isSelected(for productID: String) -> Bool
    func setSelected(_ selected: Bool, for productID: String)
}
