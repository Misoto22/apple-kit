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

    /// A loading placeholder's breath: opacity only, from 1 to `low` and back on the theme's breath curve, looping on its
    /// own view so nothing else is swept in. Still at `still` under Reduce Motion; at full opacity once `active` is false.
    public func breathing(while active: Bool = true, low: Double = 0.55, still: Double = 1) -> some View {
        modifier(Breathing(active: active, low: low, still: still))
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
    @ReduceMotion private var reduceMotion
    @Environment(\.misotoTheme) private var theme

    func body(content: Content) -> some View {
        if !active {
            content
        } else if reduceMotion {
            content.opacity(still)
        } else {
            content.phaseAnimator([1.0, low]) { view, opacity in
                view.opacity(opacity)
            } animation: { _ in
                theme.motion.breath
            }
        }
    }
}
