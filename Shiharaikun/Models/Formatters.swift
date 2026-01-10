import Foundation

enum Formatters {
    static let yen: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func dateString(_ date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = locale
        return formatter.string(from: date)
    }

    static func yen(_ amount: Double) -> String {
        let rounded = Int(amount.rounded())
        return yen(rounded)
    }

    static func yen(_ amount: Int) -> String {
        yen.string(from: NSNumber(value: amount)) ?? "¥0"
    }
}
