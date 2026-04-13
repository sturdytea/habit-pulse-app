import SwiftUI

enum AppTheme {
    static let teal = Color(red: 0.05, green: 0.58, blue: 0.53)
    static let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)
    static let deep = Color(red: 0.06, green: 0.09, blue: 0.12)
    static let card = Color(.secondarySystemGroupedBackground)
    static let subtleBorder = Color.primary.opacity(0.08)

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.12, blue: 0.11),
            Color(red: 0.02, green: 0.08, blue: 0.09)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [teal, emerald],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.subtleBorder, lineWidth: 1)
            )
    }
}

extension View {
    func habitCardStyle() -> some View {
        modifier(CardStyle())
    }
}
