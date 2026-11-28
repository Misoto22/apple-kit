import MisotoMotion
import MisotoTheme
import SwiftUI

/// Shared loading spinner whose structure, cadence, Reduce Motion gentle opacity breath, and VoiceOver label stay
/// uniform, while appearance switches among the three closed variants in `Theme.Variants.SpinnerStyle`.
public struct MisotoSpinner: View {
    public var size: CGFloat
    public var lineWidth: CGFloat
    public var variant: Theme.Variants.SpinnerStyle?
    public var tint: Color?

    @Environment(\.misotoTheme) private var theme
    @ReduceMotion private var reduceMotion
    @State private var spinning = false

    public init(
        size: CGFloat = 20,
        lineWidth: CGFloat = 2.5,
        variant: Theme.Variants.SpinnerStyle? = nil,
        tint: Color? = nil
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.variant = variant
        self.tint = tint
    }

    private var resolvedVariant: Theme.Variants.SpinnerStyle { variant ?? theme.variants.spinner }
    private var resolvedTint: Color { tint ?? theme.colors.accent }

    public var body: some View {
        Group {
            switch resolvedVariant {
            case .arc:
                arcView
            case .enso:
                ensoView
            case .markPulse:
                markPulseView
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(MisotoStrings.loading)
        .onAppear {
            guard !reduceMotion else { return }
            spinning = true
        }
        .onChange(of: reduceMotion) { _, reduced in
            spinning = !reduced
        }
    }

    private var arcView: some View {
        Circle()
            .trim(from: 0, to: 0.72)
            .stroke(resolvedTint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(spinning && !reduceMotion ? 360 : 0))
            .animation(
                Motion.unless(reduceMotion, Motion.spin),
                value: spinning
            )
            .modifier(ReducedMotionOpacityBreath(active: reduceMotion, low: 0.55))
    }

    private var ensoView: some View {
        Circle()
            .trim(from: 0.08, to: 0.92)
            .stroke(
                resolvedTint,
                style: StrokeStyle(lineWidth: lineWidth * 1.15, lineCap: .round)
            )
            .rotationEffect(.degrees(spinning && !reduceMotion ? 360 : -45))
            .animation(
                Motion.unless(reduceMotion, Motion.spinEnso),
                value: spinning
            )
            .modifier(ReducedMotionOpacityBreath(active: reduceMotion, low: 0.6))
    }

    private var markPulseView: some View {
        ZStack {
            Circle()
                .strokeBorder(resolvedTint.opacity(0.35), lineWidth: lineWidth)
                .scaleEffect(reduceMotion ? 1 : (spinning ? 1.0 : 0.78))
            Circle()
                .strokeBorder(resolvedTint, lineWidth: lineWidth)
                .padding(size * 0.16)
                .scaleEffect(reduceMotion ? 1 : (spinning ? 1.0 : 0.86))
            Circle()
                .fill(resolvedTint)
                .frame(width: max(3, size * 0.28), height: max(3, size * 0.28))
        }
        .animation(
            reduceMotion ? nil : Motion.breath.repeatForever(autoreverses: true),
            value: spinning
        )
        .modifier(ReducedMotionOpacityBreath(active: reduceMotion, low: 0.55))
    }
}

/// Opacity-only breath used specifically as the Reduce Motion fallback when orbital rotation is suppressed.
private struct ReducedMotionOpacityBreath: ViewModifier {
    let active: Bool
    let low: Double
    @State private var isLow = false

    func body(content: Content) -> some View {
        content
            .opacity(active && isLow ? low : 1)
            .onAppear { update(active) }
            .onChange(of: active) { _, now in update(now) }
            .onDisappear { isLow = false }
    }

    private func update(_ on: Bool) {
        guard on else {
            withAnimation(Motion.standard) { isLow = false }
            return
        }
        withAnimation(Motion.breath.repeatForever(autoreverses: true)) {
            isLow = true
        }
    }
}
