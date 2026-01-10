import Foundation
import SwiftUI

final class PaymentStore: ObservableObject {
    @Published private(set) var payments: [Payment] = []

    private let storageKey = "payments_v1"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.encoder = encoder
        self.decoder = decoder
        self.payments = loadPayments()
    }

    var activePayments: [Payment] {
        payments.filter { $0.isActive }
    }

    var inactivePayments: [Payment] {
        payments.filter { !$0.isActive }
    }

    func add(_ payment: Payment) {
        payments.append(payment)
        persist()
    }

    func update(_ payment: Payment) {
        guard let index = payments.firstIndex(where: { $0.id == payment.id }) else {
            return
        }
        payments[index] = payment
        persist()
    }

    func remove(_ payment: Payment) {
        payments.removeAll { $0.id == payment.id }
        persist()
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

    private func loadPayments() -> [Payment] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return (try? decoder.decode([Payment].self, from: data)) ?? []
    }

    private func persist() {
        guard let data = try? encoder.encode(payments) else {
            return
        }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
