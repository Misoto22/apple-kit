import SwiftUI

extension View {
    /// Crossfades this view's changes keyed on `value` with ``Motion/standard`` under Reduce Motion, in place of
    /// the movement the caller made instant there.
    public func fadesInsteadOfMoving(on value: some Equatable, reduceMotion: Bool) -> some View {
        modifier(FadeInsteadOfMoving(value: value, reduceMotion: reduceMotion))
    }

    /// A loading placeholder's breath: opacity only, from `1` down to `low` and back on ``Motion/breath``, repeating
    /// autoreversed. Under Reduce Motion it stands at `still`.
    public func breathing(
        while active: Bool = true,
        low: Double = Motion.breathLow,
        still: Double = 1,
        delay: Double = 0
    ) -> some View {
        modifier(Breathing(active: active, low: low, still: still, delay: delay))
    }

    /// Fades in and rises by ``Motion/enterOffset`` (`4 pt`), or crossfades on ``Motion/quick`` (`0.15 s`) only under Reduce Motion.
    public func stateRise(visible: Bool = true, delay: TimeInterval = 0) -> some View {
        modifier(StateRise(visible: visible, delay: delay))
    }

    /// Staggers arrival across sibling elements (`0.15 s + order * 0.06 s`).
    public func arrives(_ order: Int, visible: Bool = true) -> some View {
        stateRise(visible: visible, delay: Motion.fast + Double(max(0, order)) * Motion.stagger)
    }

    /// Unified press feedback: scales to ``Motion/pressScale`` (`0.96`) and dims to ``Motion/pressOpacity`` (`0.85`),
    /// instant on press and ``Motion/quick`` on release, disabling scale under Reduce Motion.
    public func pressFeedback(isPressed: Bool) -> some View {
        modifier(PressFeedback(isPressed: isPressed))
    }

    /// Numeric rolling transition gated by Reduce Motion.
    public func numericRoll() -> some View {
        modifier(NumericRoll())
    }
}

private struct FadeInsteadOfMoving<Value: Equatable>: ViewModifier {
    let value: Value
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content.transaction(value: value) { transaction in
            if reduceMotion { transaction.animation = Motion.standard }
        }
    }
}

private struct Breathing: ViewModifier {
    let active: Bool
    let low: Double
    let still: Double
    let delay: Double
    @ReduceMotion private var reduceMotion
    @State private var isLow = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion && active ? still : isLow ? low : 1)
            .onAppear { breathe(active) }
            .onChange(of: active) { _, now in breathe(now) }
            .onChange(of: reduceMotion) { _, _ in breathe(active) }
            .onDisappear { isLow = false }
    }

    private func breathe(_ on: Bool) {
        guard on, !reduceMotion else {
            withAnimation(Motion.standard) { isLow = false }
            return
        }
        withAnimation(Motion.breath.repeatForever(autoreverses: true).delay(delay)) { isLow = true }
    }
}

private struct StateRise: ViewModifier {
    let visible: Bool
    let delay: TimeInterval
    @ReduceMotion private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: (visible || reduceMotion) ? 0 : Motion.enterOffset)
            .animation((reduceMotion ? Motion.quick : Motion.standard).delay(delay), value: visible)
    }
}

private struct PressFeedback: ViewModifier {
    let isPressed: Bool
    @ReduceMotion private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed && !reduceMotion ? Motion.pressScale : 1)
            .opacity(isPressed ? Motion.pressOpacity : 1)
            .animation(Motion.press(isPressed: isPressed, reduceMotion: reduceMotion), value: isPressed)
    }
}

private struct NumericRoll: ViewModifier {
    @ReduceMotion private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.contentTransition(.numericText())
        }
    }
}
