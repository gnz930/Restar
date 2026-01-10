import SwiftUI

struct PaymentRowView: View {
    @Environment(\.locale) private var locale

    let payment: Payment
    let onMarkPaid: () -> Void
    let onToggleActive: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(payment.name)
                        .font(.custom("Avenir Next", size: 18).weight(.semibold))

                    HStack(spacing: 6) {
                        frequencyLabel
                            .font(.custom("Avenir Next", size: 13))
                            .foregroundColor(.secondary)
                        Text("・")
                            .foregroundColor(.secondary)
                        (Text("label.next_due") + Text(" ") + Text(Formatters.dateString(payment.nextDueDate, locale: locale)))
                            .font(.custom("Avenir Next", size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(Formatters.yen(payment.amountYen))
                        .font(.custom("Avenir Next", size: 18).weight(.bold))
                    (Text("label.annual_cost") + Text(" ") + Text(Formatters.yen(payment.annualCostYen)))
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                if payment.isActive {
                    Button(action: onMarkPaid) {
                        Text("action.mark_paid")
                            .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.14, green: 0.48, blue: 0.45))
                } else {
                    Text("status.paused")
                        .font(.custom("Avenir Next", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onToggleActive) {
                    Text(payment.isActive ? "action.pause" : "action.resume")
                        .font(.custom("Avenir Next", size: 13))
                }
                .buttonStyle(.bordered)
                .tint(Color(red: 0.33, green: 0.42, blue: 0.42))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }

    private var frequencyLabel: Text {
        if payment.frequencyMonths == 1 {
            return Text("frequency.monthly")
        }
        if payment.frequencyMonths == 12 {
            return Text("frequency.yearly")
        }
        return Text("frequency.every_n_months_prefix") + Text("\(payment.frequencyMonths)") + Text("frequency.every_n_months_suffix")
    }
}
