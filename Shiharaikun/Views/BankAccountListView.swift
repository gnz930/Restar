import SwiftUI

struct BankAccountListView: View {
    @EnvironmentObject private var store: PaymentStore
    @State private var showAddSheet = false
    @State private var editingAccount: BankAccount?

    var body: some View {
        List {
            if store.bankAccounts.isEmpty {
                EmptyStateView(
                    title: "master.bank.empty.title",
                    message: "master.bank.empty.message"
                )
            } else {
                ForEach(store.bankAccounts) { account in
                    HStack {
                        Text(account.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingAccount = account
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.removeBankAccount(account)
                        } label: {
                            Text("action.delete")
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("master.bank.title"))
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
            BankAccountEditorView(mode: .add) { account in
                store.addBankAccount(account)
            }
        }
        .sheet(item: $editingAccount) { account in
            BankAccountEditorView(mode: .edit(account)) { updated in
                store.updateBankAccount(updated)
            }
        }
    }
}
