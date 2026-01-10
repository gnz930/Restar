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
    @AppStorage(NotificationScheduler.globalKey) private var notificationsEnabled = false
    @AppStorage("showSummaryAmounts") private var showSummaryAmounts = true
    @State private var showAddSheet = false
    @State private var showMasterData = false
    @State private var showMethodAssignment = false
    @State private var selectedPayment: Payment?
    @State private var detailPayment: Payment?
    @State private var animateRows = false
    @State private var listMode: PaymentListMode = .upcoming
    @State private var expandedPaymentId: UUID?

    private let dueWindowDays = 7
    private let compactCardHeight: CGFloat = 150
    private let fullCardHeight: CGFloat = 260
    private let stackSpacing: CGFloat = 128
    private let expandedStackGap: CGFloat = 24

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

    private var expandedPaymentIndex: Int? {
        guard let expandedPaymentId else {
            return nil
        }
        return visiblePayments.firstIndex(where: { $0.id == expandedPaymentId })
    }

    private var expandedOffset: CGFloat {
        fullCardHeight - compactCardHeight + expandedStackGap
    }

    private var stackHeight: CGFloat {
        let count = visiblePayments.count
        guard count > 0 else {
            return 0
        }
        let baseHeight = compactCardHeight + stackSpacing * CGFloat(max(0, count - 1))
        guard let expandedIndex = expandedPaymentIndex else {
            return baseHeight
        }
        let hasBelow = count - expandedIndex - 1 > 0
        return baseHeight + (hasBelow ? expandedOffset : 0)
    }

    private var sortedInactivePayments: [Payment] {
        store.inactivePayments.sorted { $0.nextDueDate < $1.nextDueDate }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    LazyVStack(spacing: 20) {
                        actionBar

                        SummaryView(payments: store.activePayments, showAmounts: showSummaryAmounts)
                            .frame(maxWidth: .infinity)

                        listHeader

                        if store.activePayments.isEmpty {
                            EmptyStateView()
                        } else if listMode == .upcoming && upcomingPayments.isEmpty {
                            EmptyStateView(
                                title: "empty.upcoming.title",
                                message: "empty.upcoming.message"
                            )
                        } else if listMode == .all {
                            stackedAllPayments
                        } else {
                            ForEach(Array(visiblePayments.enumerated()), id: \.element.id) { index, payment in
                                paymentCard(payment, index: index)
                            }
                        }

                        if !sortedInactivePayments.isEmpty {
                            Text("section.inactive.title")
                                .font(.custom("Avenir Next", size: 14).weight(.semibold))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)

                            ForEach(sortedInactivePayments) { payment in
                                paymentCard(payment, index: 0)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("")
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
            .sheet(item: $detailPayment) { payment in
                PaymentDetailView(payment: payment) {
                    detailPayment = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedPayment = payment
                    }
                }
                .environmentObject(store)
            }
            .sheet(isPresented: $showMethodAssignment) {
                PaymentMethodAssignmentView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showMasterData) {
                MasterDataView()
                    .environmentObject(store)
            }
            .onAppear {
                if !animateRows {
                    animateRows = true
                }
                store.refreshNotifications()
            }
            .onChange(of: listMode) { newValue in
                if newValue != .all {
                    expandedPaymentId = nil
                }
            }
        }
        .environment(\.locale, appLanguage.locale)
    }

    private func paymentCard(_ payment: Payment, index: Int) -> some View {
        PaymentRowView(
            payment: payment,
            onMarkPaid: {
                store.markPaid(payment)
            },
            onToggleActive: {
                store.toggleActive(payment)
            },
            onToggleNotifications: {
                store.toggleNotifications(payment)
            },
            onShowDetail: {
                detailPayment = payment
            },
            onDelete: {
                store.remove(payment)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedPayment = payment
        }
        .opacity(animateRows ? 1 : 0)
        .offset(y: animateRows ? 0 : 14)
        .animation(.easeOut(duration: 0.35).delay(Double(index) * 0.05), value: animateRows)
    }

    private func toggleGlobalNotifications() {
        if notificationsEnabled {
            notificationsEnabled = false
            store.refreshNotifications()
            return
        }

        notificationsEnabled = true
        store.refreshNotifications()

        NotificationScheduler.requestAuthorization { granted in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                }
                store.refreshNotifications()
            }
        }
    }

    private func cycleLanguage() {
        appLanguage = appLanguage == .ja ? .en : .ja
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            ActionIconButton(
                systemImage: "globe",
                isProminent: false,
                tint: Color(red: 0.12, green: 0.45, blue: 0.54),
                action: cycleLanguage
            )
            .accessibilityLabel(Text("settings.language"))

            ActionIconButton(
                systemImage: notificationsEnabled ? "bell.fill" : "bell.slash",
                isProminent: false,
                tint: notificationsEnabled
                    ? Color(red: 0.9, green: 0.54, blue: 0.28)
                    : Color(red: 0.5, green: 0.52, blue: 0.58),
                action: toggleGlobalNotifications
            )
            .accessibilityLabel(Text(LocalizedStringKey(notificationsEnabled ? "settings.notifications_on" : "settings.notifications_off")))

            ActionIconButton(
                systemImage: showSummaryAmounts ? "eye" : "eye.slash",
                isProminent: false,
                tint: showSummaryAmounts
                    ? Color(red: 0.32, green: 0.38, blue: 0.72)
                    : Color(red: 0.52, green: 0.54, blue: 0.6),
                action: { showSummaryAmounts.toggle() }
            )
            .accessibilityLabel(Text("action.toggle_amounts"))

            ActionIconButton(
                systemImage: "creditcard",
                isProminent: false,
                tint: Color(red: 0.18, green: 0.58, blue: 0.36),
                action: { showMasterData = true }
            )
            .accessibilityLabel(Text("settings.master_data"))
            .contextMenu {
                Button("settings.method_assignment") {
                    showMethodAssignment = true
                }
            }

            Spacer()

            ActionIconButton(
                systemImage: "plus",
                isProminent: true,
                tint: Color(red: 0.12, green: 0.2, blue: 0.36),
                action: { showAddSheet = true }
            )
            .accessibilityLabel(Text("form.add_title"))
        }
        .frame(maxWidth: .infinity)
    }

    private var stackedAllPayments: some View {
        ZStack(alignment: .top) {
            ForEach(Array(visiblePayments.enumerated()), id: \.element.id) { index, payment in
                stackedPaymentCard(payment, index: index)
            }
        }
        .frame(maxWidth: .infinity, minHeight: stackHeight, alignment: .top)
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    private func stackedPaymentCard(_ payment: Payment, index: Int) -> some View {
        let isExpanded = expandedPaymentId == payment.id
        let baseOffset = CGFloat(index) * stackSpacing
        let offsetY = baseOffset + (expandedPaymentIndex.map { index > $0 ? expandedOffset : 0 } ?? 0)
        let isDimmed = expandedPaymentId != nil && !isExpanded

        return PaymentRowView(
            payment: payment,
            displayMode: isExpanded ? .full : .compact,
            onMarkPaid: {
                store.markPaid(payment)
            },
            onToggleActive: {
                store.toggleActive(payment)
            },
            onToggleNotifications: {
                store.toggleNotifications(payment)
            },
            onShowDetail: {
                detailPayment = payment
            },
            onDelete: {
                store.remove(payment)
            },
            showCompactAmount: index == 0
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                expandedPaymentId = isExpanded ? nil : payment.id
            }
        }
        .onLongPressGesture {
            selectedPayment = payment
        }
        .scaleEffect(isExpanded ? 1 : 0.97)
        .opacity(isDimmed ? 0.88 : 1)
        .offset(y: offsetY + (animateRows ? 0 : 14))
        .zIndex(isExpanded ? 100 : Double(visiblePayments.count - index))
        .animation(.easeOut(duration: 0.35).delay(Double(index) * 0.05), value: animateRows)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: expandedPaymentId)
    }

    private var listHeader: some View {
        GlassPanel(cornerRadius: 22, padding: 16, tint: Color.white) {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey(listMode.sectionTitleKey))
                    .font(.custom("Avenir Next", size: 17).weight(.semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.18, blue: 0.24))

                Picker("list.mode.label", selection: $listMode) {
                    ForEach(PaymentListMode.allCases) { mode in
                        Text(LocalizedStringKey(mode.titleKey)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color(red: 0.14, green: 0.48, blue: 0.45))
            }
        }
    }
}

private struct ActionIconButton: View {
    let systemImage: String
    let isProminent: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: isProminent ? 19 : 16, weight: .semibold))
        }
        .buttonStyle(ActionIconButtonStyle(size: isProminent ? 56 : 44, tint: tint))
    }
}

private struct ActionIconButtonStyle: ButtonStyle {
    let size: CGFloat
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(tint)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(configuration.isPressed ? 0.55 : 0.35))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
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
