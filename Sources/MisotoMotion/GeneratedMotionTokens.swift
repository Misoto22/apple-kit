// Generated from tokens/shared/misoto-motion.tokens.json by tokens/generate-shared.mjs. Do not edit.
import CoreGraphics
import Foundation

internal enum GeneratedMotionTokens {
    static let standardCurve = CubicBezier(x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    static let emphasizedCurve = CubicBezier(x1: 0.16, y1: 1.0, x2: 0.3, y2: 1.0)

    static let fast: TimeInterval = 0.15
    static let medium: TimeInterval = 0.2
    static let slowDuration: TimeInterval = 0.3
    static let breathDuration: TimeInterval = 0.8
    static let spinDuration: TimeInterval = 0.85
    static let spinEnsoDuration: TimeInterval = 1.1
    static let breathLow: Double = 0.55

    static let enterOffset: CGFloat = 4.0
    static let enterScale: CGFloat = 0.92
    static let stagger: TimeInterval = 0.06

    static let pressScale: CGFloat = 0.96
    static let pressOpacity: Double = 0.85
}
