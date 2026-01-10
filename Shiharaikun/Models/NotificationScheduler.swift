import Foundation
import UserNotifications

enum NotificationScheduler {
    static let globalKey = "notificationsEnabled"

    static var isGlobalEnabled: Bool {
        UserDefaults.standard.bool(forKey: globalKey)
    }

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                completion(granted)
            }
    }

    static func updateNotification(for payment: Payment) {
        guard shouldSchedule(for: payment) else {
            cancelNotification(for: payment)
            return
        }
        scheduleNotification(for: payment)
    }

    static func rescheduleAll(payments: [Payment]) {
        if !isGlobalEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            return
        }

        for payment in payments {
            updateNotification(for: payment)
        }
    }

    static func cancelNotification(for payment: Payment) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier(for: payment)])
    }

    private static func scheduleNotification(for payment: Payment) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.title", comment: "")

        let locale = appLocale()
        let dateString = Formatters.dateString(payment.nextDueDate, locale: locale)
        let body = String(
            format: NSLocalizedString("notification.body", comment: ""),
            payment.name,
            Formatters.yen(payment.amountYen),
            dateString
        )

        if let notes = payment.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
            let memoLine = String(format: NSLocalizedString("notification.memo", comment: ""), notes)
            content.body = body + "\n" + memoLine
        } else {
            content.body = body
        }

        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: payment.nextDueDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: payment),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private static func shouldSchedule(for payment: Payment) -> Bool {
        isGlobalEnabled && payment.isActive && payment.notificationsEnabled
    }

    private static func identifier(for payment: Payment) -> String {
        "payment-\(payment.id.uuidString)"
    }

    private static func appLocale() -> Locale {
        if let language = UserDefaults.standard.string(forKey: "appLanguage") {
            return Locale(identifier: language)
        }
        return Locale.current
    }
}
