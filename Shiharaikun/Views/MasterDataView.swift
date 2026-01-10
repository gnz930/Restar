import SwiftUI

struct MasterDataView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("master.bank.title") {
                    BankAccountListView()
                }

                NavigationLink("master.card.title") {
                    CreditCardListView()
                }
            }
            .navigationTitle(Text("master.title"))
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
