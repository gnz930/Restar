import SwiftUI

struct PaymentRowView: View {
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
                        Text(payment.frequencyLabel)
                            .font(.custom("Avenir Next", size: 13))
                            .foregroundColor(.secondary)
                        Text("・")
                            .foregroundColor(.secondary)
                        Text("次回: \(Formatters.date.string(from: payment.nextDueDate))")
                            .font(.custom("Avenir Next", size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(Formatters.yen(payment.amountYen))
                        .font(.custom("Avenir Next", size: 18).weight(.bold))
                    Text("年換算: \(Formatters.yen(payment.annualCostYen))")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                if payment.isActive {
                    Button(action: onMarkPaid) {
                        Text("支払い済みにする")
                            .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.14, green: 0.48, blue: 0.45))
                } else {
                    Text("停止中")
                        .font(.custom("Avenir Next", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onToggleActive) {
                    Text(payment.isActive ? "停止" : "再開")
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
}
