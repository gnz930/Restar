import Foundation
import SwiftUI

final class PaymentStore: ObservableObject {
    @Published private(set) var payments: [Payment] = []
    @Published private(set) var payees: [Payee] = []
    @Published private(set) var bankAccounts: [BankAccount] = []
    @Published private(set) var creditCards: [CreditCard] = []

    private let paymentsKey = "payments_v1"
    private let payeesKey = "payees_v1"
    private let bankAccountsKey = "bank_accounts_v1"
    private let creditCardsKey = "credit_cards_v1"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.encoder = encoder
        self.decoder = decoder
        self.payments = loadList(key: paymentsKey)
        self.payees = loadList(key: payeesKey)
        self.bankAccounts = loadList(key: bankAccountsKey)
        self.creditCards = loadList(key: creditCardsKey)
        seedPayeesIfNeeded()
    }

    var activePayments: [Payment] {
        payments.filter { $0.isActive }
    }

    var inactivePayments: [Payment] {
        payments.filter { !$0.isActive }
    }

    func add(_ payment: Payment) {
        payments.append(payment)
        persistPayments()
        NotificationScheduler.updateNotification(for: payment)
    }

    func update(_ payment: Payment) {
        guard let index = payments.firstIndex(where: { $0.id == payment.id }) else {
            return
        }
        payments[index] = payment
        persistPayments()
        NotificationScheduler.updateNotification(for: payment)
    }

    func remove(_ payment: Payment) {
        payments.removeAll { $0.id == payment.id }
        persistPayments()
        NotificationScheduler.cancelNotification(for: payment)
    }

    func markPaid(_ payment: Payment, paidDate: Date = Date()) {
        var updated = payment
        updated.lastPaidDate = paidDate
        update(updated)
    }

    func toggleActive(_ payment: Payment) {
        var updated = payment
        updated.isActive.toggle()
        update(updated)
    }

    func toggleNotifications(_ payment: Payment) {
        var updated = payment
        updated.notificationsEnabled.toggle()
        update(updated)
    }

    func refreshNotifications() {
        NotificationScheduler.rescheduleAll(payments: payments)
    }

    func addPayee(_ payee: Payee) {
        payees.append(payee)
        persistPayees()
    }

    func updatePayee(_ payee: Payee) {
        guard let index = payees.firstIndex(where: { $0.id == payee.id }) else {
            return
        }
        payees[index] = payee
        persistPayees()
    }

    func removePayee(_ payee: Payee) {
        payees.removeAll { $0.id == payee.id }
        payments = payments.map { payment in
            var updated = payment
            if updated.payeeId == payee.id {
                updated.payeeId = nil
            }
            return updated
        }
        persistPayees()
        persistPayments()
    }

    func addBankAccount(_ account: BankAccount) {
        bankAccounts.append(account)
        persistBankAccounts()
    }

    func updateBankAccount(_ account: BankAccount) {
        guard let index = bankAccounts.firstIndex(where: { $0.id == account.id }) else {
            return
        }
        bankAccounts[index] = account
        persistBankAccounts()
    }

    func removeBankAccount(_ account: BankAccount) {
        bankAccounts.removeAll { $0.id == account.id }
        payments = payments.map { payment in
            var updated = payment
            if updated.bankAccountId == account.id {
                updated.bankAccountId = nil
            }
            return updated
        }
        persistBankAccounts()
        persistPayments()
    }

    func addCreditCard(_ card: CreditCard) {
        creditCards.append(card)
        persistCreditCards()
    }

    func updateCreditCard(_ card: CreditCard) {
        guard let index = creditCards.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        creditCards[index] = card
        persistCreditCards()
    }

    func removeCreditCard(_ card: CreditCard) {
        creditCards.removeAll { $0.id == card.id }
        payments = payments.map { payment in
            var updated = payment
            if updated.creditCardId == card.id {
                updated.creditCardId = nil
            }
            return updated
        }
        persistCreditCards()
        persistPayments()
    }

    private func seedPayeesIfNeeded() {
        let defaultNames = ["請求書", "携帯料金合算", "Apple", "Google"]
        var existing = Set(payees.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        var didAdd = false

        for name in defaultNames {
            let key = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if existing.contains(key) {
                continue
            }
            payees.append(Payee(name: name))
            existing.insert(key)
            didAdd = true
        }

        if didAdd {
            persistPayees()
        }
    }

    private func loadList<T: Decodable>(key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        return (try? decoder.decode([T].self, from: data)) ?? []
    }

    private func persistPayments() {
        persistList(payments, key: paymentsKey)
    }

    private func persistPayees() {
        persistList(payees, key: payeesKey)
    }

    private func persistBankAccounts() {
        persistList(bankAccounts, key: bankAccountsKey)
    }

    private func persistCreditCards() {
        persistList(creditCards, key: creditCardsKey)
    }

    private func persistList<T: Encodable>(_ list: [T], key: String) {
        guard let data = try? encoder.encode(list) else {
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
}
