import SwiftUI

@main
struct ShiharaikunApp: App {
    @StateObject private var store = PaymentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
