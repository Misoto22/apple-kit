import MisotoBehavior
import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Compact pill chip with `.paper` or `.glass` surface and optional selected state.
public struct MisotoChip: View {
    private let title: LocalizedStringKey
    private let systemImage: String?
    private let isSelected: Bool
    private let action: (() -> Void)?

    @Environment(\.misotoTheme) private var theme

    public init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        isSelected: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        if let action {
            Button(action: action) { label }
                .buttonStyle(ChipButtonStyle(isSelected: isSelected))
        } else {
            label
                .foregroundStyle(isSelected ? theme.colors.onAccent : theme.colors.ink)
                .padding(.horizontal, theme.spacing.md - 4)
                .padding(.vertical, theme.spacing.xs + 2)
                .modifier(ChipBackgroundModifier(isSelected: isSelected))
        }
    }

    private var label: some View {
        HStack(spacing: theme.spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(theme.typography.caption.font)
            }
            Text(title)
                .font(theme.typography.callout.font)
        }
    }
}

private struct ChipButtonStyle: ButtonStyle {
    let isSelected: Bool
    @Environment(\.misotoTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? theme.colors.onAccent : theme.colors.ink)
            .padding(.horizontal, theme.spacing.md - 4)
            .padding(.vertical, theme.spacing.xs + 2)
            .modifier(ChipBackgroundModifier(isSelected: isSelected))
            .pressFeedback(isPressed: configuration.isPressed)
            .hitTargetOutset()
    }
}

private struct ChipBackgroundModifier: ViewModifier {
    let isSelected: Bool
    @Environment(\.misotoTheme) private var theme

    @ViewBuilder func body(content: Content) -> some View {
        if isSelected {
            content.background(theme.colors.accent, in: Capsule())
        } else if theme.variants.chipSurface == .glass {
            content.glassSurface(in: Capsule(), interactive: true)
        } else {
            content
                .background(theme.colors.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
        }
    }
}
