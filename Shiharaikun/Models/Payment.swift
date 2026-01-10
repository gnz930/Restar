import Foundation

enum PaymentMethodType: String, CaseIterable, Identifiable, Codable {
    case unspecified
    case bankTransfer
    case creditCard

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .unspecified:
            return "method.unset"
        case .bankTransfer:
            return "method.bank_transfer"
        case .creditCard:
            return "method.credit_card"
        }
    }
}

struct Payment: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var amountYen: Int
    var frequencyMonths: Int
    var lastPaidDate: Date
    var isActive: Bool
    var notificationsEnabled: Bool
    var notes: String?
    var methodType: PaymentMethodType
    var bankAccountId: UUID?
    var creditCardId: UUID?
    var payeeId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        amountYen: Int,
        frequencyMonths: Int,
        lastPaidDate: Date,
        isActive: Bool = true,
        notificationsEnabled: Bool = true,
        notes: String? = nil,
        methodType: PaymentMethodType = .unspecified,
        bankAccountId: UUID? = nil,
        creditCardId: UUID? = nil,
        payeeId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.amountYen = amountYen
        self.frequencyMonths = max(1, frequencyMonths)
        self.lastPaidDate = lastPaidDate
        self.isActive = isActive
        self.notificationsEnabled = notificationsEnabled
        self.notes = notes
        self.methodType = methodType
        self.bankAccountId = bankAccountId
        self.creditCardId = creditCardId
        self.payeeId = payeeId
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

    static func nextDueDate(from lastPaidDate: Date, frequencyMonths: Int) -> Date {
        let months = max(1, frequencyMonths)
        return Calendar.current.date(byAdding: .month, value: months, to: lastPaidDate) ?? lastPaidDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amountYen
        case frequencyMonths
        case lastPaidDate
        case isActive
        case notificationsEnabled
        case notes
        case methodType
        case bankAccountId
        case creditCardId
        case payeeId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amountYen = try container.decode(Int.self, forKey: .amountYen)
        frequencyMonths = max(1, try container.decode(Int.self, forKey: .frequencyMonths))
        lastPaidDate = try container.decode(Date.self, forKey: .lastPaidDate)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        methodType = try container.decodeIfPresent(PaymentMethodType.self, forKey: .methodType) ?? .unspecified
        bankAccountId = try container.decodeIfPresent(UUID.self, forKey: .bankAccountId)
        creditCardId = try container.decodeIfPresent(UUID.self, forKey: .creditCardId)
        payeeId = try container.decodeIfPresent(UUID.self, forKey: .payeeId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(amountYen, forKey: .amountYen)
        try container.encode(frequencyMonths, forKey: .frequencyMonths)
        try container.encode(lastPaidDate, forKey: .lastPaidDate)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(methodType, forKey: .methodType)
        try container.encodeIfPresent(bankAccountId, forKey: .bankAccountId)
        try container.encodeIfPresent(creditCardId, forKey: .creditCardId)
        try container.encodeIfPresent(payeeId, forKey: .payeeId)
    }
}
