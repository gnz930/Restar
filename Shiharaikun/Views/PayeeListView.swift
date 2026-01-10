import SwiftUI

struct PayeeListView: View {
    @EnvironmentObject private var store: PaymentStore
    @State private var showAddSheet = false
    @State private var editingPayee: Payee?

    var body: some View {
        List {
            if store.payees.isEmpty {
                EmptyStateView(
                    title: "master.payee.empty.title",
                    message: "master.payee.empty.message"
                )
            } else {
                ForEach(store.payees) { payee in
                    HStack {
                        Text(payee.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingPayee = payee
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.removePayee(payee)
                        } label: {
                            Text("action.delete")
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("master.payee.title"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            PayeeEditorView(mode: .add) { payee in
                store.addPayee(payee)
            }
        }
        .sheet(item: $editingPayee) { payee in
            PayeeEditorView(mode: .edit(payee)) { updated in
                store.updatePayee(updated)
            }
        }
    }
}
