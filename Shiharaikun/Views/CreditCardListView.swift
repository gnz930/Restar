import SwiftUI

struct CreditCardListView: View {
    @EnvironmentObject private var store: PaymentStore
    @State private var showAddSheet = false
    @State private var editingCard: CreditCard?

    var body: some View {
        List {
            if store.creditCards.isEmpty {
                EmptyStateView(
                    title: "master.card.empty.title",
                    message: "master.card.empty.message"
                )
            } else {
                ForEach(store.creditCards) { card in
                    HStack {
                        Text(card.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCard = card
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.removeCreditCard(card)
                        } label: {
                            Text("action.delete")
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("master.card.title"))
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
            CreditCardEditorView(mode: .add) { card in
                store.addCreditCard(card)
            }
        }
        .sheet(item: $editingCard) { card in
            CreditCardEditorView(mode: .edit(card)) { updated in
                store.updateCreditCard(updated)
            }
        }
    }
}
