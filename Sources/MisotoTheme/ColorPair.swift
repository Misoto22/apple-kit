import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// One colour in sRGB, 0...1 per channel.
public struct RGBA: Sendable, Hashable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// `0xRRGGBB`, the form every brand's token file writes.
    public init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    public func opacity(_ alpha: Double) -> RGBA {
        RGBA(red: red, green: green, blue: blue, alpha: self.alpha * alpha)
    }
}

/// A colour that answers the appearance: light and dark, and optionally their Increase Contrast forms.
///
/// The four apps each wrote this once (kioku's trait providers, Kura's `Pair`, Jade's `ColorPair`, Revala's asset
/// catalog). The resolution is `nonisolated` and the system calls it from any thread, so the pair holds plain values only.
public struct ColorPair: Sendable, Hashable {
    public var light: RGBA
    public var dark: RGBA
    public var lightIncreasedContrast: RGBA?
    public var darkIncreasedContrast: RGBA?

    public init(light: RGBA, dark: RGBA, lightIncreasedContrast: RGBA? = nil, darkIncreasedContrast: RGBA? = nil) {
        self.light = light
        self.dark = dark
        self.lightIncreasedContrast = lightIncreasedContrast
        self.darkIncreasedContrast = darkIncreasedContrast
    }

    public init(light: UInt32, dark: UInt32) {
        self.init(light: RGBA(hex: light), dark: RGBA(hex: dark))
    }

    /// One value in both appearances.
    public init(_ fixed: RGBA) {
        self.init(light: fixed, dark: fixed)
    }

    public func resolve(dark isDark: Bool, increasedContrast: Bool) -> RGBA {
        switch (isDark, increasedContrast) {
        case (false, false): light
        case (true, false): dark
        case (false, true): lightIncreasedContrast ?? light
        case (true, true): darkIncreasedContrast ?? dark
        }
    }

    public func opacity(_ alpha: Double) -> ColorPair {
        ColorPair(
            light: light.opacity(alpha),
            dark: dark.opacity(alpha),
            lightIncreasedContrast: lightIncreasedContrast?.opacity(alpha),
            darkIncreasedContrast: darkIncreasedContrast?.opacity(alpha)
        )
    }
}

#if canImport(UIKit)
extension UIColor {
    public convenience init(_ pair: ColorPair) {
        self.init { traits in
            let value = pair.resolve(
                dark: traits.userInterfaceStyle == .dark,
                increasedContrast: traits.accessibilityContrast == .high
            )
            return UIColor(red: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
        }
    }
}

extension Color {
    public init(_ pair: ColorPair) {
        self.init(uiColor: UIColor(pair))
    }
}
#elseif canImport(AppKit)
extension NSColor {
    public convenience init(_ pair: ColorPair) {
        self.init(name: nil) { appearance in
            let match = appearance.bestMatch(from: [
                .aqua, .darkAqua, .accessibilityHighContrastAqua, .accessibilityHighContrastDarkAqua,
            ])
            let value = pair.resolve(
                dark: match == .darkAqua || match == .accessibilityHighContrastDarkAqua,
                increasedContrast: match == .accessibilityHighContrastAqua || match == .accessibilityHighContrastDarkAqua
            )
            return NSColor(srgbRed: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
        }
    }
}

extension Color {
    public init(_ pair: ColorPair) {
        self.init(nsColor: NSColor(pair))
    }
}
#endif
