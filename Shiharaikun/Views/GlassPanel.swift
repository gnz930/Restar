import SwiftUI

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 22
    var padding: CGFloat = 18
    var tint: Color = Color.white
    var shadowOpacity: Double = 0.12

    private let content: Content

    init(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 18,
        tint: Color = Color.white,
        shadowOpacity: Double = 0.12,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.tint = tint
        self.shadowOpacity = shadowOpacity
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.65),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(shadowOpacity), radius: 18, x: 0, y: 12)
            )
    }
}
