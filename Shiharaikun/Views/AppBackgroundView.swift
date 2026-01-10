import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.95),
                    Color(red: 0.88, green: 0.94, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.55, green: 0.78, blue: 0.76).opacity(0.25))
                .frame(width: 220, height: 220)
                .offset(x: 140, y: -220)

            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(18))
                .offset(x: -160, y: 240)
        }
        .ignoresSafeArea()
    }
}
