import SwiftUI

struct SummaryView: View {
    let payments: [Payment]

    private var monthlyTotal: Double {
        payments.reduce(0) { $0 + $1.monthlyCostYen }
    }

    private var annualTotal: Double {
        payments.reduce(0) { $0 + $1.annualCostYen }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("summary.monthly_total")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundColor(.secondary)
                    Text(Formatters.yen(monthlyTotal))
                        .font(.custom("Avenir Next", size: 26).weight(.bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("summary.annual_total")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundColor(.secondary)
                    Text(Formatters.yen(annualTotal))
                        .font(.custom("Avenir Next", size: 24).weight(.bold))
                        .foregroundColor(.primary)
                }
            }

            HStack {
                Text("summary.items_label")
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundColor(.secondary)
                (Text("\(payments.count)") + Text("summary.items_suffix"))
                    .font(.custom("Avenir Next", size: 14).weight(.semibold))
                    .foregroundColor(Color(red: 0.14, green: 0.48, blue: 0.45))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color(red: 0.93, green: 0.98, blue: 0.97)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
    }
}
