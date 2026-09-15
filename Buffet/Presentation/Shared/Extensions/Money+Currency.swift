import Foundation

extension Money {
    /// The format used wherever a price is shown to the customer, e.g. `¥12.34`.
    static let currencyFormat = Decimal.FormatStyle.Currency(
        code: "CNY",
        locale: Locale(identifier: "zh_CN")
    )
}
