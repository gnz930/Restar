import SwiftUI

struct ContentView: View {
    enum PaymentListMode: CaseIterable, Identifiable {
        case upcoming
        case all

        var id: Self { self }

        var titleKey: String {
            switch self {
            case .upcoming:
                return "list.mode.upcoming"
            case .all:
                return "list.mode.all"
            }
        }

        var sectionTitleKey: String {
            switch self {
            case .upcoming:
                return "section.upcoming.title"
            case .all:
                return "section.all.title"
            }
        }
    }

    @EnvironmentObject private var store: PaymentStore
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .ja
    @State private var showAddSheet = false
    @State private var selectedPayment: Payment?
    @State private var animateRows = false
    @State private var listMode: PaymentListMode = .upcoming

    private let dueWindowDays = 7

    private var upcomingPayments: [Payment] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let windowEnd = calendar.date(byAdding: .day, value: dueWindowDays, to: today) else {
            return store.activePayments
        }

        return store.activePayments
            .filter { payment in
                let dueDate = calendar.startOfDay(for: payment.nextDueDate)
                return dueDate <= windowEnd
            }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    private var visiblePayments: [Payment] {
        switch listMode {
        case .upcoming:
            return upcomingPayments
        case .all:
            return store.activePayments.sorted { $0.nextDueDate < $1.nextDueDate }
        }
    }

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

                    Section(header: listHeader) {
                        if store.activePayments.isEmpty {
                            EmptyStateView()
                        } else if listMode == .upcoming && upcomingPayments.isEmpty {
                            EmptyStateView(
                                title: "empty.upcoming.title",
                                message: "empty.upcoming.message"
                            )
                        } else {
                            ForEach(Array(visiblePayments.enumerated()), id: \.element.id) { index, payment in
                                paymentRow(payment, index: index)
                            }
                        }
                    }

                    if !store.inactivePayments.isEmpty {
                        Section(header: Text("section.inactive.title")) {
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
            .navigationTitle(Text("app.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("settings.language", selection: $appLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(LocalizedStringKey(language.titleKey)).tag(language)
                            }
                        }
                    } label: {
                        Label("settings.language", systemImage: "globe")
                    }
                }
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
                Text("action.delete")
            }
        }
    }

    private var listHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(listMode.sectionTitleKey))
            Picker("list.mode.label", selection: $listMode) {
                ForEach(PaymentListMode.allCases) { mode in
                    Text(LocalizedStringKey(mode.titleKey)).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .textCase(nil)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PaymentStore())
            .environment(\.locale, Locale(identifier: "ja"))
    }
}
#endif
