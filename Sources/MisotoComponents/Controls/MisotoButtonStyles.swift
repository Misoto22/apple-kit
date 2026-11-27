import MisotoBehavior
import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Primary CTA button style (`capsule` or `roundedRect`, `solid` or `glass`, 44 pt hit target, unified press feedback).
public struct MisotoPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: Configuration
        @Environment(\.misotoTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        private var cornerRadius: CGFloat {
            theme.variants.buttonShape == .capsule ? 999 : theme.radii.control
        }

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            configuration.label
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.variants.buttonFill == .glass ? theme.colors.ink : theme.colors.onAccent)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.sm + 4)
                .frame(minHeight: 44)
                .background {
                    if theme.variants.buttonFill == .glass {
                        Color.clear.glassSurface(in: shape, interactive: true)
                    } else {
                        shape.fill(theme.colors.accent)
                    }
                }
                .opacity(isEnabled ? 1 : 0.45)
                .pressFeedback(isPressed: configuration.isPressed && isEnabled)
                .hitTargetOutset()
        }
    }
}

/// Secondary button style.
public struct MisotoSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: Configuration
        @Environment(\.misotoTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        private var cornerRadius: CGFloat {
            theme.variants.buttonShape == .capsule ? 999 : theme.radii.control
        }

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            configuration.label
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.colors.ink)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.sm + 4)
                .frame(minHeight: 44)
                .background(theme.colors.surface, in: shape)
                .overlay(shape.strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
                .opacity(isEnabled ? 1 : 0.45)
                .pressFeedback(isPressed: configuration.isPressed && isEnabled)
                .hitTargetOutset()
        }
    }
}

/// Circular icon button style adapting to glass or paper surface.
public struct MisotoIconButtonStyle: ButtonStyle {
    public var size: CGFloat

    public init(size: CGFloat = 36) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration, size: size)
    }

    private struct BodyView: View {
        let configuration: Configuration
        let size: CGFloat
        @Environment(\.misotoTheme) private var theme
        @Environment(\.standsOnGlass) private var standsOnGlass
        @Environment(\.isEnabled) private var isEnabled

        private var useGlass: Bool {
            standsOnGlass || theme.variants.iconButtonSurface == .glassCircle
        }

        var body: some View {
            configuration.label
                .foregroundStyle(theme.colors.ink)
                .frame(width: size, height: size)
                .background {
                    if useGlass {
                        Color.clear.glassSurface(in: Circle(), interactive: true)
                    } else {
                        Circle().fill(theme.colors.surface)
                            .overlay(Circle().strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
                    }
                }
                .opacity(isEnabled ? 1 : 0.45)
                .pressFeedback(isPressed: configuration.isPressed && isEnabled)
                .hitTargetOutset()
        }
    }
}

/// Quiet inline text button style (`dim` or `wash` press feedback).
public struct MisotoTextButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: Configuration
        @Environment(\.misotoTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(theme.typography.callout.font)
                .foregroundStyle(theme.colors.accent)
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, 2)
                .background {
                    if theme.variants.textButtonFeedback == .wash && configuration.isPressed {
                        RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                            .fill(theme.colors.glass.wash)
                    }
                }
                .opacity(isEnabled ? (configuration.isPressed && theme.variants.textButtonFeedback == .dim ? Motion.pressOpacity : 1) : 0.45)
                .hitTargetOutset()
        }
    }
}

extension ButtonStyle where Self == MisotoPrimaryButtonStyle {
    public static var misotoPrimary: MisotoPrimaryButtonStyle { MisotoPrimaryButtonStyle() }
}

extension ButtonStyle where Self == MisotoSecondaryButtonStyle {
    public static var misotoSecondary: MisotoSecondaryButtonStyle { MisotoSecondaryButtonStyle() }
}

extension ButtonStyle where Self == MisotoIconButtonStyle {
    public static var misotoIcon: MisotoIconButtonStyle { MisotoIconButtonStyle() }
}

extension ButtonStyle where Self == MisotoTextButtonStyle {
    public static var misotoText: MisotoTextButtonStyle { MisotoTextButtonStyle() }
}

/// Action button showing an inline `MisotoSpinner` and disabling taps while `isBusy` is true.
public struct MisotoBusyButton: View {
    private let title: LocalizedStringKey
    private let isBusy: Bool
    private let action: () -> Void

    @Environment(\.misotoTheme) private var theme

    public init(_ title: LocalizedStringKey, isBusy: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isBusy = isBusy
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.sm) {
                if isBusy {
                    MisotoSpinner(size: 16, lineWidth: 2)
                }
                Text(title)
            }
        }
        .buttonStyle(.misotoPrimary)
        .disabled(isBusy)
    }
}
