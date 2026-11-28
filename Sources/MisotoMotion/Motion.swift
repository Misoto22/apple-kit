import Foundation
import SwiftUI

#if canImport(QuartzCore) && !os(watchOS)
import QuartzCore
#endif

/// A cubic Bezier timing curve `(x1, y1, x2, y2)` shared across SwiftUI, Core Animation, CSS, and Kotlin.
public struct CubicBezier: Sendable, Hashable {
    public var x1: Double
    public var y1: Double
    public var x2: Double
    public var y2: Double

    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    /// SwiftUI `Animation` with the given `duration`.
    public func animation(duration: TimeInterval) -> Animation {
        .timingCurve(x1, y1, x2, y2, duration: duration)
    }

    #if canImport(QuartzCore) && !os(watchOS)
    /// Core Animation `CAMediaTimingFunction` for UIKit / AppKit (`NSAnimationContext`, `CATransaction`) callers.
    public var caMediaTimingFunction: CAMediaTimingFunction {
        CAMediaTimingFunction(
            controlPoints: Float(x1), Float(y1), Float(x2), Float(y2)
        )
    }
    #endif

    /// Evaluates `y(x)` at normalized progress `x` in `0...1` via Newton-Raphson with bisection fallback.
    public func value(_ x: Double) -> Double {
        if x <= 0 { return 0 }
        if x >= 1 { return 1 }

        var t = x
        for _ in 0..<8 {
            let currentX = sampleCurveX(t) - x
            if abs(currentX) < 1e-6 { break }
            let dx = sampleCurveDerivativeX(t)
            if abs(dx) < 1e-6 { break }
            t -= currentX / dx
        }

        if t < 0 || t > 1 {
            var low = 0.0
            var high = 1.0
            t = x
            for _ in 0..<24 {
                let currentX = sampleCurveX(t)
                if abs(currentX - x) < 1e-6 { break }
                if x > currentX { low = t } else { high = t }
                t = 0.5 * (low + high)
            }
        }
        return sampleCurveY(t)
    }

    private func sampleCurveX(_ t: Double) -> Double {
        let cx = 3 * x1
        let bx = 3 * (x2 - x1) - cx
        let ax = 1 - cx - bx
        return ((ax * t + bx) * t + cx) * t
    }

    private func sampleCurveY(_ t: Double) -> Double {
        let cy = 3 * y1
        let by = 3 * (y2 - y1) - cy
        let ay = 1 - cy - by
        return ((ay * t + by) * t + cy) * t
    }

    private func sampleCurveDerivativeX(_ t: Double) -> Double {
        let cx = 3 * x1
        let bx = 3 * (x2 - x1) - cx
        let ax = 1 - cx - bx
        return (3 * ax * t + 2 * bx) * t + cx
    }
}

/// Numerical solver for Misoto's standard curve, for `TimelineView` frame-by-frame interpolation.
public enum StandardEasing {
    public static func value(_ progress: Double) -> Double {
        Motion.standardCurve.value(progress)
    }
}

/// Unified motion vocabulary across all Misoto apps (generated from `tokens/shared/misoto-motion.tokens.json`).
public enum Motion {
    public static let standardCurve = GeneratedMotionTokens.standardCurve
    public static let emphasizedCurve = GeneratedMotionTokens.emphasizedCurve

    public static let fast: TimeInterval = GeneratedMotionTokens.fast
    public static let medium: TimeInterval = GeneratedMotionTokens.medium
    public static let slowDuration: TimeInterval = GeneratedMotionTokens.slowDuration
    public static let breathDuration: TimeInterval = GeneratedMotionTokens.breathDuration
    public static let spinDuration: TimeInterval = GeneratedMotionTokens.spinDuration
    public static let spinEnsoDuration: TimeInterval = GeneratedMotionTokens.spinEnsoDuration
    public static let breathLow: Double = GeneratedMotionTokens.breathLow

    public static let enterOffset: CGFloat = GeneratedMotionTokens.enterOffset
    public static let enterScale: CGFloat = GeneratedMotionTokens.enterScale
    public static let stagger: TimeInterval = GeneratedMotionTokens.stagger

    public static let pressScale: CGFloat = GeneratedMotionTokens.pressScale
    public static let pressOpacity: Double = GeneratedMotionTokens.pressOpacity

    /// Something under the finger: a press, a selection, a subtle shift.
    public static let quick = standardCurve.animation(duration: fast)
    /// Content arriving, leaving, or resizing.
    public static let standard = standardCurve.animation(duration: medium)
    /// Larger spatial transitions.
    public static let slow = standardCurve.animation(duration: slowDuration)
    /// Segmented controls, toggles, numeric counters.
    public static let snappy = Animation.snappy(duration: slowDuration)
    /// Signature arrivals without overshoot.
    public static let emphasized = emphasizedCurve.animation(duration: slowDuration)
    /// Single cycle of a loading placeholder's breath.
    public static let breath = standardCurve.animation(duration: breathDuration)
    /// Continuous linear rotation cycle for standard activity arcs.
    public static let spin = Animation.linear(duration: spinDuration).repeatForever(autoreverses: false)
    /// Continuous linear rotation cycle for calligraphy enso activity indicators.
    public static let spinEnso = Animation.linear(duration: spinEnsoDuration).repeatForever(autoreverses: false)

    /// `animation`, or `nil` when system Reduce Motion is on.
    @MainActor
    public static func unlessReduced(_ animation: Animation?) -> Animation? {
        ReducedMotion.unlessReduced(animation)
    }

    /// `animation`, or `nil` when `reduceMotion` is on.
    public static func unless(_ reduceMotion: Bool, _ animation: Animation?) -> Animation? {
        ReducedMotion.unless(reduceMotion, animation)
    }

    /// Press highlight animation: instant on press (`nil`), `release` on lift (suppressed under Reduce Motion).
    @MainActor
    public static func press(isPressed: Bool, release: Animation = quick) -> Animation? {
        isPressed ? nil : unlessReduced(release)
    }

    /// Press highlight animation driven by an explicit `reduceMotion` flag from `@ReduceMotion`.
    public static func press(isPressed: Bool, reduceMotion: Bool, release: Animation = quick) -> Animation? {
        isPressed ? nil : unless(reduceMotion, release)
    }

    /// Layer handoff: the leaving layer fades out on `quick`; the arriving layer delays by `fast` before fading in on `standard`.
    @MainActor
    public static func fold(arriving: Bool) -> Animation? {
        unlessReduced(arriving ? standard.delay(fast) : quick)
    }

    /// Layer handoff driven by an explicit `reduceMotion` flag from `@ReduceMotion`.
    public static func fold(arriving: Bool, reduceMotion: Bool) -> Animation? {
        unless(reduceMotion, arriving ? standard.delay(fast) : quick)
    }
}
