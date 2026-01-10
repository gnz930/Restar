import SwiftUI

struct PaymentFormView: View {
    enum Mode {
        case add
        case edit(Payment)

        var title: String {
            switch self {
            case .add:
                return "支払いを追加"
            case .edit:
                return "支払いを編集"
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

    enum FrequencyChoice: String, CaseIterable, Identifiable {
        case monthly = "毎月"
        case yearly = "毎年"
        case custom = "nヶ月ごと"

        var id: String { rawValue }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (Payment) -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var frequencyChoice: FrequencyChoice
    @State private var customMonths: Int
    @State private var lastPaidDate: Date
    @State private var isActive: Bool
    @State private var notes: String

    init(mode: Mode, onSave: @escaping (Payment) -> Void) {
        self.mode = mode
        self.onSave = onSave

        let payment = mode.payment
        _name = State(initialValue: payment?.name ?? "")
        _amountText = State(initialValue: payment.map { String($0.amountYen) } ?? "")
        _lastPaidDate = State(initialValue: payment?.lastPaidDate ?? Date())
        _isActive = State(initialValue: payment?.isActive ?? true)
        _notes = State(initialValue: payment?.notes ?? "")

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
                Section(header: Text("基本情報")) {
                    TextField("支払い名", text: $name)
                        .textInputAutocapitalization(.never)

                    TextField("金額 (円)", text: $amountText)
                        .keyboardType(.numberPad)

                    Text("入力中: \(Formatters.yen(amountValue))")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(.secondary)
                }

                Section(header: Text("頻度")) {
                    Picker("頻度", selection: $frequencyChoice) {
                        ForEach(FrequencyChoice.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    if frequencyChoice == .custom {
                        Stepper("\(customMonths)ヶ月ごと", value: $customMonths, in: 2...24)
                    }

                    HStack {
                        Text("次回予定")
                        Spacer()
                        Text(Formatters.date.string(from: nextDueDate))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("直近の支払日")) {
                    DatePicker("日付", selection: $lastPaidDate, displayedComponents: .date)
                }

                Section(header: Text("ステータス")) {
                    Toggle("この支払いを続ける", isOn: $isActive)
                }

                Section(header: Text("メモ")) {
                    TextField("例: 年払い、カード決済", text: $notes, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                }

                Section(header: Text("サマリー")) {
                    HStack {
                        Text("年換算")
                        Spacer()
                        Text(Formatters.yen(Double(amountValue) * 12.0 / Double(max(1, frequencyMonths))))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("月間換算")
                        Spacer()
                        Text(Formatters.yen(Double(amountValue) / Double(max(1, frequencyMonths))))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let payment = Payment(
                            id: mode.payment?.id ?? UUID(),
                            name: trimmed,
                            amountYen: amountValue,
                            frequencyMonths: frequencyMonths,
                            lastPaidDate: lastPaidDate,
                            isActive: isActive,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
                        )
                        onSave(payment)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
