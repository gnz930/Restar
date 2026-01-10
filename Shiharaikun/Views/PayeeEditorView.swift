import SwiftUI

struct PayeeEditorView: View {
    enum Mode {
        case add
        case edit(Payee)

        var titleKey: String {
            switch self {
            case .add:
                return "editor.payee.add"
            case .edit:
                return "editor.payee.edit"
            }
        }

        var payee: Payee? {
            switch self {
            case .add:
                return nil
            case .edit(let payee):
                return payee
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (Payee) -> Void

    @State private var name: String
    @State private var note: String

    init(mode: Mode, onSave: @escaping (Payee) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.payee?.name ?? "")
        _note = State(initialValue: mode.payee?.note ?? "")
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("editor.section.basic")) {
                    TextField("editor.name", text: $name)
                    TextField("editor.note", text: $note, axis: .vertical)
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
                        let noteValue = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        let payee = Payee(
                            id: mode.payee?.id ?? UUID(),
                            name: trimmed,
                            note: noteValue.isEmpty ? nil : noteValue
                        )
                        onSave(payee)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
