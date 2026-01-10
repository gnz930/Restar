import SwiftUI

struct PaymentRowView: View {
    enum DisplayMode {
        case full
        case compact
    }

    @Environment(\.locale) private var locale
    @EnvironmentObject private var store: PaymentStore
    @GestureState private var isPressed = false

    let payment: Payment
    let displayMode: DisplayMode
    let onMarkPaid: () -> Void
    let onToggleActive: () -> Void
    let onToggleNotifications: () -> Void
    let onShowDetail: () -> Void
    let onDelete: () -> Void
    let showCompactAmount: Bool


    init(
        payment: Payment,
        displayMode: DisplayMode = .full,
        onMarkPaid: @escaping () -> Void,
        onToggleActive: @escaping () -> Void,
        onToggleNotifications: @escaping () -> Void,
        onShowDetail: @escaping () -> Void = {},
        onDelete: @escaping () -> Void,
        showCompactAmount: Bool = true
    ) {
        self.payment = payment
        self.displayMode = displayMode
        self.onMarkPaid = onMarkPaid
        self.onToggleActive = onToggleActive
        self.onToggleNotifications = onToggleNotifications
        self.onShowDetail = onShowDetail
        self.onDelete = onDelete
        self.showCompactAmount = showCompactAmount
    }

    private var palette: CardPalette {
        CardPalette.palette(for: payment.id)
    }

    private var primaryTextColor: Color {
        Color(red: 0.08, green: 0.12, blue: 0.16)
    }

    private var secondaryTextColor: Color {
        Color(red: 0.22, green: 0.28, blue: 0.34)
    }

    private var mutedTextColor: Color {
        Color(red: 0.36, green: 0.42, blue: 0.48)
    }

    private var notificationsTitleKey: LocalizedStringKey {
        LocalizedStringKey(payment.notificationsEnabled ? "action.notifications_on" : "action.notifications_off")
    }

    private var notificationsIcon: String {
        payment.notificationsEnabled ? "bell.fill" : "bell.slash"
    }

    private var isCompact: Bool {
        displayMode == .compact
    }

    var body: some View {
        let pressGesture = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }

        ZStack {
            cardBackground
            cardContent
        }
        .frame(minHeight: isCompact ? 150 : 260)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 12)
        .scaleEffect(isPressed ? 0.985 : 1)
        .rotation3DEffect(.degrees(isPressed ? 1.5 : 0), axis: (x: 1, y: 0, z: 0))
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isPressed)
        .saturation(payment.isActive ? 1 : 0.35)
        .opacity(payment.isActive ? 1 : 0.9)
        .simultaneousGesture(pressGesture)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(palette.tintGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isPressed ? 0.28 : 0.18),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(palette.borderGradient, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(palette.glow.opacity(0.45))
                    .blur(radius: 30)
            )
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 14) {
            if isCompact {
                compactHeader
                compactAmountStack
            } else {
                fullHeader
                fullAmountRow
                detailSummary
                actionRow
            }
        }
        .padding(isCompact ? 16 : 18)
    }

    private var compactHeader: some View {
        HStack(alignment: .top) {
            Text(payment.name)
                .font(.custom("Avenir Next", size: 18).weight(.semibold))
                .foregroundColor(primaryTextColor)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Spacer()

            nextDueBadge
        }
    }

    private var compactAmountStack: some View {
        Group {
            if showCompactAmount {
                Text(Formatters.yen(payment.amountYen))
                    .font(.custom("Avenir Next", size: 24).weight(.bold))
                    .foregroundColor(Color.black)
                    .monospacedDigit()
            }
        }
    }

    private var fullHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(payment.name)
                    .font(.custom("Avenir Next", size: 20).weight(.semibold))
                    .foregroundColor(primaryTextColor)

                VStack(alignment: .leading, spacing: 4) {
                    frequencyLabel
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(secondaryTextColor)

                    payeeLine
                        .font(.custom("Avenir Next", size: 11))
                        .foregroundColor(mutedTextColor)

                    methodLine
                        .font(.custom("Avenir Next", size: 11))
                        .foregroundColor(mutedTextColor)
                }
            }

            Spacer()

            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("action.delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(primaryTextColor.opacity(0.6))
            }
            .accessibilityLabel(Text("action.more"))
        }
    }


    private var fullAmountRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Formatters.yen(payment.amountYen))
                    .font(.custom("Avenir Next", size: 28).weight(.bold))
                    .foregroundColor(Color.black)
                    .monospacedDigit()

                (Text("label.annual_cost") + Text(" ") + Text(Formatters.yen(payment.annualCostYen)))
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(secondaryTextColor)
            }

            Spacer()

            nextDueBadge
        }
    }

    private var detailSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            detailRow("detail.last_paid", value: Formatters.dateString(payment.lastPaidDate, locale: locale))

            if let notes = payment.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                detailRow("detail.notes", value: notes, allowMultiline: true)
            }
        }
    }

    private var actionRow: some View {
        HStack {
            if payment.isActive {
                CardActionButton(
                    titleKey: "action.mark_paid",
                    systemImage: "checkmark.circle.fill",
                    action: onMarkPaid
                )
            } else {
                pausedBadge
            }

            Spacer()

            HStack(spacing: 8) {
                CardIconButton(
                    systemImage: "info.circle",
                    action: onShowDetail
                )
                .accessibilityLabel(Text("action.details"))

                CardActionButton(
                    titleKey: notificationsTitleKey,
                    systemImage: notificationsIcon,
                    action: onToggleNotifications
                )

                CardActionButton(
                    titleKey: payment.isActive ? "action.pause" : "action.resume",
                    systemImage: payment.isActive ? "pause.fill" : "play.fill",
                    action: onToggleActive
                )
            }
        }
    }

    private var nextDueBadge: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("label.next_due")
                .font(.custom("Avenir Next", size: 10))
                .foregroundColor(secondaryTextColor)

            Text(Formatters.dateString(payment.nextDueDate, locale: locale))
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(primaryTextColor)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(isCompact ? 0.55 : 0.65))
        )
    }

    private func detailRow(_ titleKey: String, value: String, allowMultiline: Bool = false) -> some View {
        HStack(alignment: allowMultiline ? .top : .center) {
            Text(LocalizedStringKey(titleKey))
                .font(.custom("Avenir Next", size: 11))
                .foregroundColor(mutedTextColor)

            Spacer()

            Text(value)
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(primaryTextColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(allowMultiline ? 2 : 1)
        }
    }


    private var payeeLine: Text {
        let name = store.payees.first(where: { $0.id == payment.payeeId })?.displayName
        if let name {
            return Text("label.payee") + Text(" ") + Text(name)
        }
        return Text("label.payee") + Text(" ") + Text("value.unset")
    }

    private var methodLine: Text {
        switch payment.methodType {
        case .bankTransfer:
            let name = store.bankAccounts.first(where: { $0.id == payment.bankAccountId })?.displayName
            let detail = name.map(Text.init) ?? Text("value.unset")
            return Text("label.method") + Text(" ") + Text("method.bank_transfer") + Text(" ") + detail
        case .creditCard:
            let name = store.creditCards.first(where: { $0.id == payment.creditCardId })?.displayName
            let detail = name.map(Text.init) ?? Text("value.unset")
            return Text("label.method") + Text(" ") + Text("method.credit_card") + Text(" ") + detail
        case .unspecified:
            return Text("label.method") + Text(" ") + Text("method.unset")
        }
    }

    private var pausedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "pause.circle.fill")
            Text("status.paused")
        }
        .font(.custom("Avenir Next", size: 12).weight(.semibold))
        .foregroundColor(primaryTextColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.6))
        )
    }

    private var frequencyLabel: Text {
        if payment.frequencyMonths == 1 {
            return Text("frequency.monthly")
        }
        if payment.frequencyMonths == 12 {
            return Text("frequency.yearly")
        }
        return Text("frequency.every_n_months_prefix") + Text("\(payment.frequencyMonths)") + Text("frequency.every_n_months_suffix")
    }
}

private struct CardActionButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(titleKey)
            }
            .font(.custom("Avenir Next", size: 12).weight(.semibold))
            .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.16))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.65))
            )
        }
        .buttonStyle(GlassActionButtonStyle())
    }
}

private struct CardIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.16))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.65))
                )
        }
        .buttonStyle(GlassActionButtonStyle())
    }
}

private struct GlassActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct CardPalette {
    let tintGradient: LinearGradient
    let borderGradient: LinearGradient
    let glow: Color

    static func palette(for id: UUID) -> CardPalette {
        let seed = id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palettes[seed % palettes.count]
    }

    private static let palettes: [CardPalette] = [
        CardPalette(
            tintGradient: LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.45, blue: 0.54).opacity(0.35),
                    Color(red: 0.26, green: 0.72, blue: 0.78).opacity(0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            borderGradient: LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color(red: 0.45, green: 0.86, blue: 0.88).opacity(0.5),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glow: Color(red: 0.56, green: 0.9, blue: 0.86)
        ),
        CardPalette(
            tintGradient: LinearGradient(
                colors: [
                    Color(red: 0.72, green: 0.34, blue: 0.22).opacity(0.32),
                    Color(red: 0.95, green: 0.64, blue: 0.34).opacity(0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            borderGradient: LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color(red: 0.98, green: 0.76, blue: 0.46).opacity(0.55),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glow: Color(red: 0.98, green: 0.78, blue: 0.54)
        ),
        CardPalette(
            tintGradient: LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.26, blue: 0.36).opacity(0.34),
                    Color(red: 0.32, green: 0.56, blue: 0.52).opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            borderGradient: LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color(red: 0.5, green: 0.84, blue: 0.74).opacity(0.5),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glow: Color(red: 0.6, green: 0.86, blue: 0.74)
        ),
        CardPalette(
            tintGradient: LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.32, blue: 0.48).opacity(0.34),
                    Color(red: 0.36, green: 0.66, blue: 0.82).opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            borderGradient: LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color(red: 0.62, green: 0.88, blue: 0.96).opacity(0.55),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            glow: Color(red: 0.62, green: 0.88, blue: 0.96)
        )
    ]
}
