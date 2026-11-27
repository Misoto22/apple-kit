import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Unified toggle style switching between `.switch` and `.check` via `Theme.Variants.ToggleVariant`.
public struct MisotoToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: Configuration
        @Environment(\.misotoTheme) private var theme
        @ReduceMotion private var reduceMotion

        var body: some View {
            HStack {
                configuration.label
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.ink)
                Spacer(minLength: theme.spacing.sm)
                control
            }
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(Motion.unless(reduceMotion, Motion.snappy)) {
                    configuration.isOn.toggle()
                }
            }
            .accessibilityAddTraits(.isButton)
        }

        @ViewBuilder
        private var control: some View {
            switch theme.variants.toggle {
            case .switch:
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule(style: .continuous)
                        .fill(configuration.isOn ? theme.colors.accent : theme.colors.hairline)
                        .frame(width: 48, height: 28)
                    Circle()
                        .fill(theme.colors.onAccent)
                        .frame(width: 24, height: 24)
                        .padding(2)
                }
                .hitTargetOutset()
            case .check:
                ZStack {
                    RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                        .fill(configuration.isOn ? theme.colors.accent : theme.colors.surface)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                                .strokeBorder(configuration.isOn ? theme.colors.accent : theme.colors.hairline, lineWidth: theme.elevation.strokeWidth)
                        )
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(theme.colors.onAccent)
                    }
                }
                .hitTargetOutset()
            }
        }
    }
}

extension ToggleStyle where Self == MisotoToggleStyle {
    public static var misoto: MisotoToggleStyle { MisotoToggleStyle() }
}
