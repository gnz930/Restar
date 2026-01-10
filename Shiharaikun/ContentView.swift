import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PaymentStore
    @State private var showAddSheet = false
    @State private var selectedPayment: Payment?
    @State private var animateRows = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                List {
                    Section {
                        SummaryView(payments: store.activePayments)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }

                    Section(header: Text("支払い一覧")) {
                        if store.activePayments.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(Array(store.activePayments.enumerated()), id: \.element.id) { index, payment in
                                paymentRow(payment, index: index)
                            }
                        }
                    }

                    if !store.inactivePayments.isEmpty {
                        Section(header: Text("停止中")) {
                            ForEach(store.inactivePayments) { payment in
                                paymentRow(payment, index: 0)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("しはらいくん")
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
                PaymentFormView(mode: .add) { payment in
                    store.add(payment)
                }
            }
            .sheet(item: $selectedPayment) { payment in
                PaymentFormView(mode: .edit(payment)) { updated in
                    store.update(updated)
                }
            }
            .onAppear {
                if !animateRows {
                    animateRows = true
                }
            }
        }
    }

    private func paymentRow(_ payment: Payment, index: Int) -> some View {
        PaymentRowView(
            payment: payment,
            onMarkPaid: {
                store.markPaid(payment)
            },
            onToggleActive: {
                store.toggleActive(payment)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedPayment = payment
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.vertical, 6)
        .opacity(animateRows ? 1 : 0)
        .offset(y: animateRows ? 0 : 16)
        .animation(.easeOut(duration: 0.35).delay(Double(index) * 0.05), value: animateRows)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                store.remove(payment)
            } label: {
                Text("削除")
            }
        }
    }
}
