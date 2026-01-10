import SwiftUI

struct CreditCardEditorView: View {
    enum Mode {
        case add
        case edit(CreditCard)

        var titleKey: String {
            switch self {
            case .add:
                return "editor.card.add"
            case .edit:
                return "editor.card.edit"
            }
        }

        var card: CreditCard? {
            switch self {
            case .add:
                return nil
            case .edit(let card):
                return card
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (CreditCard) -> Void

    @State private var name: String
    @State private var last4: String

    init(mode: Mode, onSave: @escaping (CreditCard) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.card?.name ?? "")
        _last4 = State(initialValue: mode.card?.last4 ?? "")
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("editor.section.basic")) {
                    TextField("editor.card.name", text: $name)

                    TextField("editor.card.last4", text: $last4)
                        .keyboardType(.numberPad)
                        .onChange(of: last4) { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            let trimmed = String(digits.prefix(4))
                            if trimmed != newValue {
                                last4 = trimmed
                            }
                        }
                }
            }
            .navigationTitle(Text(mode.titleKey))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("editor.cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("editor.save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let last4Value = last4.trimmingCharacters(in: .whitespacesAndNewlines)
                        let card = CreditCard(
                            id: mode.card?.id ?? UUID(),
                            name: trimmed,
                            last4: last4Value.isEmpty ? nil : last4Value
                        )
                        onSave(card)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
