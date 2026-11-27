import CoreGraphics
import SwiftUI

/// One shadow token: offset, blur, spread, and colour.
public struct ShadowToken: Sendable, Hashable {
    public var x: CGFloat
    public var y: CGFloat
    public var blur: CGFloat
    public var spread: CGFloat
    public var color: RGBA

    public init(x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat = 0, color: RGBA) {
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
        self.color = color
    }

    public var swiftUIColor: Color {
        Color(.sRGB, red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}

/// Appearance-aware shadow token pair.
public struct ShadowPair: Sendable, Hashable {
    public var light: ShadowToken
    public var dark: ShadowToken

    public init(light: ShadowToken, dark: ShadowToken) {
        self.light = light
        self.dark = dark
    }

    public init(_ fixed: ShadowToken) {
        self.light = fixed
        self.dark = fixed
    }

    public func resolve(for colorScheme: ColorScheme) -> ShadowToken {
        colorScheme == .dark ? dark : light
    }
}
