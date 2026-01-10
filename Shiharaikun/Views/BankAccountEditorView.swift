import SwiftUI

struct BankAccountEditorView: View {
    enum Mode {
        case add
        case edit(BankAccount)

        var titleKey: String {
            switch self {
            case .add:
                return "editor.bank.add"
            case .edit:
                return "editor.bank.edit"
            }
        }

        var account: BankAccount? {
            switch self {
            case .add:
                return nil
            case .edit(let account):
                return account
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (BankAccount) -> Void

    @State private var name: String
    @State private var detail: String

    init(mode: Mode, onSave: @escaping (BankAccount) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.account?.name ?? "")
        _detail = State(initialValue: mode.account?.detail ?? "")
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("editor.section.basic")) {
                    TextField("editor.bank.name", text: $name)
                    TextField("editor.bank.detail", text: $detail, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
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
                        let detailValue = detail.trimmingCharacters(in: .whitespacesAndNewlines)
                        let account = BankAccount(
                            id: mode.account?.id ?? UUID(),
                            name: trimmed,
                            detail: detailValue.isEmpty ? nil : detailValue
                        )
                        onSave(account)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
