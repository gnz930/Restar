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
        GlassPanel(cornerRadius: 22, padding: 20, tint: Color.white) {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(Color(red: 0.3, green: 0.42, blue: 0.44))

                Text(title)
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.16, blue: 0.2))

                Text(message)
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
