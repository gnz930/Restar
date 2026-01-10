import Foundation

struct Payee: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var note: String?

    init(id: UUID = UUID(), name: String, note: String? = nil) {
        self.id = id
        self.name = name
        self.note = note
    }

    var displayName: String {
        name
    }
}
