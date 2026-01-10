import SwiftUI

struct PaymentFormView: View {
    enum Mode {
        case add
        case edit(Payment)

        var titleKey: String {
            switch self {
            case .add:
                return "form.add_title"
            case .edit:
                return "form.edit_title"
            }
        }

        var payment: Payment? {
            switch self {
            case .add:
                return nil
            case .edit(let payment):
                return payment
            }
        }
    }

    enum FrequencyChoice: CaseIterable, Identifiable {
        case monthly
        case yearly
        case custom

        var id: Self { self }

        var titleKey: String {
            switch self {
            case .monthly:
                return "frequency.monthly"
            case .yearly:
                return "frequency.yearly"
            case .custom:
                return "frequency.custom"
            }
        }
    }

    @EnvironmentObject private var store: PaymentStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    let mode: Mode
    let onSave: (Payment) -> Void

    @State private var showMasterData = false
    @State private var name: String
    @State private var amountText: String
    @State private var frequencyChoice: FrequencyChoice
    @State private var customMonths: Int
    @State private var lastPaidDate: Date
    @State private var isActive: Bool
    @State private var notes: String
    @State private var methodType: PaymentMethodType
    @State private var selectedPayeeId: UUID?
    @State private var selectedBankAccountId: UUID?
    @State private var selectedCardId: UUID?

    init(mode: Mode, onSave: @escaping (Payment) -> Void) {
        self.mode = mode
        self.onSave = onSave

        let payment = mode.payment
        _name = State(initialValue: payment?.name ?? "")
        _amountText = State(initialValue: payment.map { String($0.amountYen) } ?? "")
        _lastPaidDate = State(initialValue: payment?.lastPaidDate ?? Date())
        _isActive = State(initialValue: payment?.isActive ?? true)
        _notes = State(initialValue: payment?.notes ?? "")
        _methodType = State(initialValue: payment?.methodType ?? .unspecified)
        _selectedPayeeId = State(initialValue: payment?.payeeId)
        _selectedBankAccountId = State(initialValue: payment?.bankAccountId)
        _selectedCardId = State(initialValue: payment?.creditCardId)

        let months = payment?.frequencyMonths ?? 1
        if months == 1 {
            _frequencyChoice = State(initialValue: .monthly)
            _customMonths = State(initialValue: 2)
        } else if months == 12 {
            _frequencyChoice = State(initialValue: .yearly)
            _customMonths = State(initialValue: 2)
        } else {
            _frequencyChoice = State(initialValue: .custom)
            _customMonths = State(initialValue: months)
        }
    }

    private var frequencyMonths: Int {
        switch frequencyChoice {
        case .monthly:
            return 1
        case .yearly:
            return 12
        case .custom:
            return customMonths
        }
    }

    private var amountValue: Int {
        let digits = amountText.filter { $0.isNumber }
        return Int(digits) ?? 0
    }

    private var nextDueDate: Date {
        Payment.nextDueDate(from: lastPaidDate, frequencyMonths: frequencyMonths)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amountValue > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("form.section.basic")) {
                    TextField("form.name_placeholder", text: $name)
                        .textInputAutocapitalization(.never)

                    TextField("form.amount_placeholder", text: $amountText)
                        .keyboardType(.numberPad)

                    (Text("form.input_amount_prefix") + Text(Formatters.yen(amountValue)))
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(.secondary)
                }

                Section(header: Text("form.section.payee")) {
                    if store.payees.isEmpty {
                        Text("form.payee_empty")
                            .font(.custom("Avenir Next", size: 12))
                            .foregroundColor(.secondary)

                        Button("form.manage_master") {
                            showMasterData = true
                        }
                    } else {
                        Picker("form.payee_picker", selection: $selectedPayeeId) {
                            Text("value.unset").tag(UUID?.none)
                            ForEach(store.payees) { payee in
                                Text(payee.displayName).tag(Optional(payee.id))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section(header: Text("form.section.method")) {
                    Picker("form.method_picker", selection: $methodType) {
                        ForEach(PaymentMethodType.allCases) { method in
                            Text(LocalizedStringKey(method.titleKey)).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("form.method_hint")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(.secondary)
                }

                Section(header: Text("form.section.frequency")) {
                    Picker("form.frequency_picker", selection: $frequencyChoice) {
                        ForEach(FrequencyChoice.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    if frequencyChoice == .custom {
                        Stepper(value: $customMonths, in: 2...24) {
                            frequencyEveryNMonthsLabel(customMonths)
                        }
                    }

                    HStack {
                        Text("form.next_due")
                        Spacer()
                        Text(Formatters.dateString(nextDueDate, locale: locale))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("form.section.last_paid")) {
                    DatePicker("form.date_label", selection: $lastPaidDate, displayedComponents: .date)
                }

                Section(header: Text("form.section.status")) {
                    Toggle("form.toggle_active", isOn: $isActive)
                }

                Section(header: Text("form.section.notes")) {
                    TextField("form.notes_placeholder", text: $notes, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                }

                Section(header: Text("form.section.summary")) {
                    HStack {
                        Text("form.annual_label")
                        Spacer()
                        Text(Formatters.yen(Double(amountValue) * 12.0 / Double(max(1, frequencyMonths))))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("form.monthly_label")
                        Spacer()
                        Text(Formatters.yen(Double(amountValue) / Double(max(1, frequencyMonths))))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey(mode.titleKey)))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("form.cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("form.save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let methodBankId = methodType == .bankTransfer ? selectedBankAccountId : nil
                        let methodCardId = methodType == .creditCard ? selectedCardId : nil
                        let payment = Payment(
                            id: mode.payment?.id ?? UUID(),
                            name: trimmed,
                            amountYen: amountValue,
                            frequencyMonths: frequencyMonths,
                            lastPaidDate: lastPaidDate,
                            isActive: isActive,
                            notificationsEnabled: mode.payment?.notificationsEnabled ?? true,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
                            methodType: methodType,
                            bankAccountId: methodBankId,
                            creditCardId: methodCardId,
                            payeeId: selectedPayeeId
                        )
                        onSave(payment)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showMasterData) {
                MasterDataView()
                    .environmentObject(store)
            }
        }
    }

    private func frequencyEveryNMonthsLabel(_ months: Int) -> Text {
        Text("frequency.every_n_months_prefix") + Text("\(months)") + Text("frequency.every_n_months_suffix")
    }
}
