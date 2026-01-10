import SwiftUI

struct SummaryView: View {
    let payments: [Payment]
    let showAmounts: Bool

    private var monthlyTotal: Double {
        payments.reduce(0) { $0 + $1.monthlyCostYen }
    }

    private var annualTotal: Double {
        payments.reduce(0) { $0 + $1.annualCostYen }
    }

    var body: some View {
        GlassPanel(cornerRadius: 24, padding: 18, tint: Color.white) {
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("summary.monthly_total")
                            .font(.custom("Avenir Next", size: 13).weight(.semibold))
                            .foregroundColor(.secondary)

                        Text(showAmounts ? Formatters.yen(monthlyTotal) : "----")
                            .font(.custom("Avenir Next", size: 26).weight(.bold))
                            .foregroundColor(Color(red: 0.08, green: 0.16, blue: 0.2))
                            .monospacedDigit()
                    }

                    HStack(spacing: 8) {
                        Text("summary.items_label")
                            .font(.custom("Avenir Next", size: 12).weight(.semibold))
                            .foregroundColor(.secondary)

                        (Text("\(payments.count)") + Text("summary.items_suffix"))
                            .font(.custom("Avenir Next", size: 12).weight(.semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.38, blue: 0.44))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.55))
                            )
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("summary.annual_total")
                        .font(.custom("Avenir Next", size: 11).weight(.semibold))
                        .foregroundColor(.secondary)

                    Text(showAmounts ? Formatters.yen(annualTotal) : "----")
                        .font(.custom("Avenir Next", size: 14).weight(.semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.26, blue: 0.3))
                        .monospacedDigit()
                }
                .padding(.bottom, 2)
            }
        }
    }
}
