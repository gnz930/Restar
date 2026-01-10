import Foundation

struct CreditCard: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var last4: String?

    init(id: UUID = UUID(), name: String, last4: String? = nil) {
        self.id = id
        self.name = name
        self.last4 = last4
    }

    var displayName: String {
        let trimmed = last4?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            return name
        }
        return "\(name) (****\(trimmed))"
    }
}
