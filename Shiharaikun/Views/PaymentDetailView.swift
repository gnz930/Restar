import SwiftUI

struct PaymentDetailView: View {
    @EnvironmentObject private var store: PaymentStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    let payment: Payment
    let onEdit: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("detail.section.summary") {
                    LabeledContent("detail.amount", value: Formatters.yen(payment.amountYen))
                    LabeledContent("detail.next_due", value: Formatters.dateString(payment.nextDueDate, locale: locale))
                    LabeledContent("detail.last_paid", value: Formatters.dateString(payment.lastPaidDate, locale: locale))
                    LabeledContent("detail.frequency", value: frequencyText)
                    LabeledContent("detail.annual_cost", value: Formatters.yen(payment.annualCostYen))
                    LabeledContent("detail.monthly_cost", value: Formatters.yen(payment.monthlyCostYen))
                }

                Section("detail.section.method") {
                    LabeledContent("detail.payee", value: payeeName)
                    LabeledContent("detail.method", value: methodDescription)
                }

                if let notes = payment.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                    Section("detail.section.notes") {
                        Text(notes)
                            .font(.custom("Avenir Next", size: 14))
                            .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle(Text("detail.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("master.done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("action.edit") {
                        onEdit()
                    }
                }
            }
        }
    }

    private var payeeName: String {
        guard let payeeId = payment.payeeId else {
            return localized("value.unset")
        }
        return store.payees.first(where: { $0.id == payeeId })?.displayName ?? localized("value.unset")
    }

    private var methodDescription: String {
        let methodName = localized(payment.methodType.titleKey)
        switch payment.methodType {
        case .bankTransfer:
            let accountName = store.bankAccounts.first(where: { $0.id == payment.bankAccountId })?.displayName
                ?? localized("value.unset")
            return "\(methodName) / \(accountName)"
        case .creditCard:
            let cardName = store.creditCards.first(where: { $0.id == payment.creditCardId })?.displayName
                ?? localized("value.unset")
            return "\(methodName) / \(cardName)"
        case .unspecified:
            return methodName
        }
    }

    private var frequencyText: String {
        if payment.frequencyMonths == 1 {
            return localized("frequency.monthly")
        }
        if payment.frequencyMonths == 12 {
            return localized("frequency.yearly")
        }
        let prefix = localized("frequency.every_n_months_prefix")
        let suffix = localized("frequency.every_n_months_suffix")
        return "\(prefix)\(payment.frequencyMonths)\(suffix)"
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
