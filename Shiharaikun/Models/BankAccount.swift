import Foundation

struct BankAccount: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var detail: String?

    init(id: UUID = UUID(), name: String, detail: String? = nil) {
        self.id = id
        self.name = name
        self.detail = detail
    }

    var displayName: String {
        let trimmedDetail = detail?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedDetail.isEmpty {
            return name
        }
        return "\(name) (\(trimmedDetail))"
    }
}
