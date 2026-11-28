import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Empty state view sharing layout, spacing, Dynamic Type, and Reduce Motion across apps,
/// with `.symbol` vs `.illustrated` variants and optional brand artwork slot.
public struct MisotoEmptyState<Artwork: View>: View {
    public enum Placement: Sendable { case fullScreen, inline }

    private let systemImage: String
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let placement: Placement
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?
    private let artwork: Artwork

    @Environment(\.misotoTheme) private var theme

    public init(
        systemImage: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        placement: Placement = .fullScreen,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder artwork: () -> Artwork
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.placement = placement
        self.actionTitle = actionTitle
        self.action = action
        self.artwork = artwork()
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            Group {
                switch theme.variants.emptyState {
                case .symbol:
                    Image(systemName: systemImage)
                        .font(placement == .fullScreen ? .largeTitle : .title2)
                        .foregroundStyle(theme.colors.secondaryInk)
                case .illustrated:
                    artwork
                }
            }
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

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.misotoPrimary)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .padding(placement == .fullScreen ? theme.spacing.xl : theme.spacing.lg)
        .readableWidth(maxWidth: 420)
        .frame(maxHeight: placement == .fullScreen ? .infinity : nil)
    }
}

extension MisotoEmptyState where Artwork == EmptyView {
    public init(
        systemImage: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        placement: Placement = .fullScreen,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.init(
            systemImage: systemImage,
            title: title,
            message: message,
            placement: placement,
            actionTitle: actionTitle,
            action: action
        ) {
            EmptyView()
        }
    }
}
