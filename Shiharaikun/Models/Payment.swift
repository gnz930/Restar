import Foundation

struct Payment: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var amountYen: Int
    var frequencyMonths: Int
    var lastPaidDate: Date
    var isActive: Bool
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        amountYen: Int,
        frequencyMonths: Int,
        lastPaidDate: Date,
        isActive: Bool = true,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amountYen = amountYen
        self.frequencyMonths = max(1, frequencyMonths)
        self.lastPaidDate = lastPaidDate
        self.isActive = isActive
        self.notes = notes
    }

    var nextDueDate: Date {
        Payment.nextDueDate(from: lastPaidDate, frequencyMonths: frequencyMonths)
    }

    var annualCostYen: Double {
        Double(amountYen) * 12.0 / Double(max(1, frequencyMonths))
    }

    var monthlyCostYen: Double {
        Double(amountYen) / Double(max(1, frequencyMonths))
    }

    var frequencyLabel: String {
        if frequencyMonths == 1 {
            return "毎月"
        }
        if frequencyMonths == 12 {
            return "毎年"
        }
        return "\(frequencyMonths)ヶ月ごと"
    }

    static func nextDueDate(from lastPaidDate: Date, frequencyMonths: Int) -> Date {
        let months = max(1, frequencyMonths)
        return Calendar.current.date(byAdding: .month, value: months, to: lastPaidDate) ?? lastPaidDate
    }
}
