import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundColor(Color(red: 0.46, green: 0.56, blue: 0.55))

            Text("まだ登録がありません")
                .font(.custom("Avenir Next", size: 16).weight(.semibold))

            Text("右上の + から支払いを追加できます")
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}
