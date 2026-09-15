import Foundation

struct Money: Equatable, Comparable, AdditiveArithmetic, Sendable {
    static let zero = Money(amount: .zero)

    let amount: Decimal

    init(amount: Decimal) {
        self.amount = amount
    }

    init?(decimalString: String) {
        guard let amount = Decimal(string: decimalString, locale: Locale(identifier: "en_US_POSIX")) else {
            return nil
        }
        self.init(amount: amount)
    }

    static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.amount < rhs.amount
    }

    static func + (lhs: Money, rhs: Money) -> Money {
        Money(amount: lhs.amount + rhs.amount)
    }

    static func - (lhs: Money, rhs: Money) -> Money {
        Money(amount: lhs.amount - rhs.amount)
    }

    static func * (lhs: Money, rhs: Int) -> Money {
        Money(amount: lhs.amount * Decimal(rhs))
    }
}
