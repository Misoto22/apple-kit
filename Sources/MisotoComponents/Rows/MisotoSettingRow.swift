import MisotoTheme
import SwiftUI

/// Atomic setting row (`card` or `plain` style). Page-level settings skeletons remain in each app.
public struct MisotoSettingRow<Trailing: View>: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let systemImage: String?
    private let trailing: Trailing
    private let action: (() -> Void)?

    @Environment(\.misotoTheme) private var theme

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        systemImage: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
        self.trailing = trailing()
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { rowContent }
                    .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: theme.spacing.md) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(theme.colors.accent)
                    .frame(width: 24)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption.font)
                        .foregroundStyle(theme.colors.secondaryInk)
                }
            }
            Spacer(minLength: theme.spacing.sm)
            trailing
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm + 4)
        .modifier(SettingRowBackgroundModifier())
    }
}

extension MisotoSettingRow where Trailing == EmptyView {
    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        systemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.init(title, subtitle: subtitle, systemImage: systemImage, action: action) {
            EmptyView()
        }
    }
}

private struct SettingRowBackgroundModifier: ViewModifier {
    @Environment(\.misotoTheme) private var theme

    @ViewBuilder func body(content: Content) -> some View {
        if theme.variants.settingRow == .card {
            let shape = RoundedRectangle(cornerRadius: theme.radii.medium, style: .continuous)
            content
                .background(theme.colors.surface, in: shape)
                .overlay(shape.strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
        } else {
            content.background(theme.colors.paper)
        }
    }
}
