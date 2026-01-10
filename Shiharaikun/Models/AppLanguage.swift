import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case ja
    case en

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .ja:
            return "language.japanese"
        case .en:
            return "language.english"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
