import MisotoLayout
import MisotoTheme
import SwiftUI

/// Recoverable error state with severity styling and unified retry affordance.
public struct MisotoErrorState: View {
    public enum Severity: Sendable { case info, warning, critical }
    public enum Placement: Sendable { case fullScreen, inline }

    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let severity: Severity
    private let placement: Placement
    private let retryAction: (() -> Void)?

    @Environment(\.misotoTheme) private var theme

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        severity: Severity = .critical,
        placement: Placement = .fullScreen,
        retry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.severity = severity
        self.placement = placement
        self.retryAction = retry
    }

    private var iconColor: Color {
        switch severity {
        case .info: theme.colors.accent
        case .warning: theme.colors.warning
        case .critical: theme.colors.error
        }
    }

    private var iconName: String {
        switch severity {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .critical: "exclamationmark.circle"
        }
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: iconName)
                .font(placement == .fullScreen ? .largeTitle.weight(.medium) : .title2.weight(.medium))
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)

            VStack(spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.headline.font)
                    .foregroundStyle(theme.colors.ink)
                    .multilineTextAlignment(.center)
                if let message {
                    Text(message)
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.secondaryInk)
                        .multilineTextAlignment(.center)
                }
            }

            if let retryAction {
                Button(MisotoStrings.retry, action: retryAction)
                    .buttonStyle(.misotoSecondary)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .padding(placement == .fullScreen ? theme.spacing.xl : theme.spacing.lg)
        .readableWidth(maxWidth: 420)
        .frame(maxHeight: placement == .fullScreen ? .infinity : nil)
    }
}
