import SwiftUI

@main
struct ShiharaikunApp: App {
    @StateObject private var store = PaymentStore()
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .ja

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environment(\.locale, appLanguage.locale)
        }
    }
}
