import SwiftUI

struct EmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    init(
        title: LocalizedStringKey = "empty.default.title",
        message: LocalizedStringKey = "empty.default.message"
    ) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundColor(Color(red: 0.46, green: 0.56, blue: 0.55))

            Text(title)
                .font(.custom("Avenir Next", size: 16).weight(.semibold))

            Text(message)
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}
