import SwiftUI

struct AppBackgroundView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.95, blue: 1.0),
                    Color(red: 0.88, green: 0.94, blue: 0.98),
                    Color(red: 0.95, green: 0.97, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.42, green: 0.76, blue: 0.84).opacity(0.45),
                            Color(red: 0.42, green: 0.76, blue: 0.84).opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 18)
                .offset(x: animate ? 170 : 120, y: animate ? -210 : -250)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.98, green: 0.68, blue: 0.56).opacity(0.4),
                            Color(red: 0.98, green: 0.68, blue: 0.56).opacity(0.06)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 22)
                .offset(x: animate ? -200 : -150, y: animate ? 220 : 260)

            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(18))
                .offset(x: animate ? -130 : -90, y: animate ? -40 : -10)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
