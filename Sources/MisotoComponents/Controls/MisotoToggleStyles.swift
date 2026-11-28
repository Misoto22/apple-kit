import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Unified toggle style switching between `.switch` and `.check` via `Theme.Variants.ToggleVariant` (or an explicit
/// `variant` parameter), with VoiceOver value announcement, disabled state dimming, and Dynamic Type scaling.
public struct MisotoToggleStyle: ToggleStyle {
    public var variant: Theme.Variants.ToggleVariant?
    public var tint: Color?
    public var track: Color?

    public init(
        variant: Theme.Variants.ToggleVariant? = nil,
        tint: Color? = nil,
        track: Color? = nil
    ) {
        self.variant = variant
        self.tint = tint
        self.track = track
    }

    public func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration, variant: variant, tint: tint, track: track)
    }

    private struct BodyView: View {
        let configuration: Configuration
        let variant: Theme.Variants.ToggleVariant?
        let tint: Color?
        let track: Color?
        @Environment(\.misotoTheme) private var theme
        @Environment(\.isEnabled) private var isEnabled
        @ReduceMotion private var reduceMotion
        @ScaledMetric(relativeTo: .body) private var switchWidth: CGFloat = 48
        @ScaledMetric(relativeTo: .body) private var switchHeight: CGFloat = 28
        @ScaledMetric(relativeTo: .body) private var switchKnob: CGFloat = 24
        @ScaledMetric(relativeTo: .body) private var switchPadding: CGFloat = 2
        @ScaledMetric(relativeTo: .body) private var checkSize: CGFloat = 24

        private var resolvedVariant: Theme.Variants.ToggleVariant { variant ?? theme.variants.toggle }
        private var resolvedTint: Color { tint ?? theme.colors.accent }
        private var resolvedTrack: Color { track ?? theme.colors.hairline }

        var body: some View {
            Button {
                withAnimation(Motion.unless(reduceMotion, Motion.snappy)) {
                    configuration.isOn.toggle()
                }
            } label: {
                HStack {
                    configuration.label
                        .font(theme.typography.body.font)
                        .foregroundStyle(isEnabled ? theme.colors.ink : theme.colors.secondaryInk)
                    Spacer(minLength: theme.spacing.sm)
                    control
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .opacity(isEnabled ? 1 : 0.45)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(configuration.isOn ? MisotoStrings.toggleOn : MisotoStrings.toggleOff)
        }

        @ViewBuilder
        private var control: some View {
            switch resolvedVariant {
            case .switch:
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule(style: .continuous)
                        .fill(configuration.isOn ? resolvedTint : resolvedTrack)
                        .frame(width: switchWidth, height: switchHeight)
                    Circle()
                        .fill(theme.colors.onAccent)
                        .frame(width: switchKnob, height: switchKnob)
                        .padding(switchPadding)
                }
                .hitTargetOutset()
            case .check:
                ZStack {
                    RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                        .fill(configuration.isOn ? resolvedTint : theme.colors.surface)
                        .frame(width: checkSize, height: checkSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                                .strokeBorder(
                                    configuration.isOn ? resolvedTint : resolvedTrack,
                                    lineWidth: theme.elevation.strokeWidth
                                )
                        )
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
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
