import MisotoTheme
import SwiftUI

/// Inline notice banner (`info`, `warning`, `error`).
public struct MisotoBanner: View {
    public enum Tone: Sendable { case info, warning, error }

    private let tone: Tone
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    @Environment(\.misotoTheme) private var theme

    public init(
        tone: Tone = .info,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    private var tint: Color {
        switch tone {
        case .info: theme.colors.accent
        case .warning: theme.colors.warning
        case .error: theme.colors.error
        }
    }

    private var iconName: String {
        switch tone {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: iconName)
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.headline.font)
                    .foregroundStyle(theme.colors.ink)
                if let message {
                    Text(message)
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.secondaryInk)
                }
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.misotoText)
                        .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(theme.spacing.md)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: theme.radii.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.medium, style: .continuous)
                .strokeBorder(tint.opacity(0.25), lineWidth: theme.elevation.strokeWidth)
        )
    }
}
