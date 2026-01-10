import SwiftUI

struct PaymentMethodAssignmentView: View {
    @EnvironmentObject private var store: PaymentStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        if store.payments.isEmpty {
                            EmptyStateView(
                                title: "method_assign.empty.title",
                                message: "method_assign.empty.message"
                            )
                        } else {
                            ForEach(store.payments) { payment in
                                PaymentMethodAssignmentRow(payment: payment)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle(Text("method_assign.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("master.done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct PaymentMethodAssignmentRow: View {
    @EnvironmentObject private var store: PaymentStore

    let payment: Payment

    var body: some View {
        GlassPanel(cornerRadius: 22, padding: 16, tint: Color.white) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(payment.name)
                        .font(.custom("Avenir Next", size: 16).weight(.semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.18, blue: 0.24))

                    Spacer()

                    Text(LocalizedStringKey(payment.methodType.titleKey))
                        .font(.custom("Avenir Next", size: 11).weight(.semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.38, blue: 0.44))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.6))
                        )
                }

                methodAssignmentSection
            }
        }
    }

    @ViewBuilder
    private var methodAssignmentSection: some View {
        switch payment.methodType {
        case .bankTransfer:
            if store.bankAccounts.isEmpty {
                Text("method_assign.bank_empty")
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(.secondary)
            } else {
                Picker("method_assign.select_bank", selection: bankAccountSelection) {
                    Text("value.unset").tag(UUID?.none)
                    ForEach(store.bankAccounts) { account in
                        Text(account.displayName).tag(Optional(account.id))
                    }
                }
                .pickerStyle(.menu)
            }
        case .creditCard:
            if store.creditCards.isEmpty {
                Text("method_assign.card_empty")
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(.secondary)
            } else {
                Picker("method_assign.select_card", selection: cardSelection) {
                    Text("value.unset").tag(UUID?.none)
                    ForEach(store.creditCards) { card in
                        Text(card.displayName).tag(Optional(card.id))
                    }
                }
                .pickerStyle(.menu)
            }
        case .unspecified:
            Text("method_assign.unset")
                .font(.custom("Avenir Next", size: 12))
                .foregroundColor(.secondary)
        }
    }

    private var bankAccountSelection: Binding<UUID?> {
        Binding(
            get: { payment.bankAccountId },
            set: { newValue in
                updatePayment { updated in
                    updated.bankAccountId = newValue
                    updated.creditCardId = nil
                }
            }
        )
    }

    private var cardSelection: Binding<UUID?> {
        Binding(
            get: { payment.creditCardId },
            set: { newValue in
                updatePayment { updated in
                    updated.creditCardId = newValue
                    updated.bankAccountId = nil
                }
            }
        )
    }

    private func updatePayment(_ transform: (inout Payment) -> Void) {
        var updated = payment
        transform(&updated)
        store.update(updated)
    }
}
