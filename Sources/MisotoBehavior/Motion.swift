import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Reduce Motion, decided in one place: movement becomes a fade or nothing, never a choice each page makes.
public enum ReducedMotion {
    /// The system setting, for code outside a view (a transaction, UIKit).
    @MainActor public static var isOn: Bool {
        #if canImport(UIKit)
        UIAccessibility.isReduceMotionEnabled
        #elseif canImport(AppKit)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #endif
    }

    /// `animation`, or nil when Reduce Motion is on: the change lands at once.
    @MainActor public static func unlessReduced(_ animation: Animation?) -> Animation? {
        isOn ? nil : animation
    }

    /// `animation`, or nil when `reduceMotion` is set: for a view that read the environment.
    public static func unless(_ reduceMotion: Bool, _ animation: Animation?) -> Animation? {
        reduceMotion ? nil : animation
    }
}

extension EnvironmentValues {
    /// Forces Reduce Motion on below, whatever the system says: a debug gallery's switch, a test.
    @Entry public var forcesReduceMotion: Bool = false
}

/// Whether motion is reduced here: the system's setting, or `\.forcesReduceMotion`.
@propertyWrapper
public struct ReduceMotion: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var system
    @Environment(\.forcesReduceMotion) private var forced

    public init() {}

    public var wrappedValue: Bool { system || forced }
}

extension View {
    /// Crossfades this view's changes keyed on `value` with the theme's standard curve under Reduce Motion, in place of
    /// the movement the caller made instant there. With motion on it leaves the transaction alone, so the movement's
    /// own animation carries this view.
    public func fadesInsteadOfMoving(on value: some Equatable, reduceMotion: Bool) -> some View {
        modifier(FadeInsteadOfMoving(value: value, reduceMotion: reduceMotion))
    }

    /// A loading placeholder's breath: opacity only, from 1 down to `low` and back on the theme's breath curve, repeating
    /// with the descent played backwards (autoreverse), so nothing else is swept in. `delay` offsets a neighbour's breath.
    /// When `active` turns false it eases back to full opacity on the theme's standard curve, never in one frame. Under
    /// Reduce Motion it stands at `still`.
    public func breathing(while active: Bool = true, low: Double = 0.55, still: Double = 1, delay: Double = 0) -> some View {
        modifier(Breathing(active: active, low: low, still: still, delay: delay))
    }
}

private struct FadeInsteadOfMoving<Value: Equatable>: ViewModifier {
    let value: Value
    let reduceMotion: Bool
    @Environment(\.misotoTheme) private var theme

    func body(content: Content) -> some View {
        content.transaction(value: value) { transaction in
            if reduceMotion { transaction.animation = theme.motion.standard }
        }
    }
}

private struct Breathing: ViewModifier {
    let active: Bool
    let low: Double
    let still: Double
    let delay: Double
    @ReduceMotion private var reduceMotion
    @Environment(\.misotoTheme) private var theme
    @State private var isLow = false

    func body(content: Content) -> some View {
        // One structure throughout, so turning the breath off eases back rather than rebuilding the content.
        content
            .opacity(reduceMotion && active ? still : isLow ? low : 1)
            .onAppear { breathe(active) }
            .onChange(of: active) { _, now in breathe(now) }
            .onChange(of: reduceMotion) { _, _ in breathe(active) }
            .onDisappear { isLow = false }
    }

    private func breathe(_ on: Bool) {
        guard on, !reduceMotion else {
            // Back to full opacity on the standard curve, which also ends the repeating breath.
            withAnimation(theme.motion.standard) { isLow = false }
            return
        }
        // The delay offsets only the first breath; every cycle after it follows on at once.
        withAnimation(theme.motion.breath.repeatForever(autoreverses: true).delay(delay)) { isLow = true }
    }
}
