import MisotoTheme
import SwiftUI

/// A colour that switches between its plain token and its glass-contrast token based on `\.standsOnGlass`.
public struct GlassInkStyle: ShapeStyle, Sendable {
    public let plain: Color
    public let glass: Color

    public init(plain: Color, glass: Color) {
        self.plain = plain
        self.glass = glass
    }

    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        color(onGlass: environment.standsOnGlass).resolve(in: environment)
    }

    public func color(onGlass: Bool) -> Color {
        onGlass ? glass : plain
    }
}

/// Translucent fills for controls resting on glass (`Theme.Colors.Glass`).
public enum GlassFill {
    public static func wash(in theme: Theme) -> Color { theme.colors.glass.wash }
    public static func band(in theme: Theme) -> Color { theme.colors.glass.band }
}

private struct GlassSurfaceModifier<S: InsettableShape>: ViewModifier {
    let shape: S
    let interactive: Bool
    @Environment(\.misotoTheme) private var theme
    @ReduceTransparency private var reduceTransparency

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .background(theme.colors.paper, in: shape)
                .overlay(shape.strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
        } else {
            content
                .glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        }
    }
}

extension View {
    /// Applies system Liquid Glass in `shape`, automatically falling back to solid `theme.colors.paper` when Reduce Transparency is on.
    public func glassSurface<S: InsettableShape>(in shape: S, interactive: Bool = false) -> some View {
        modifier(GlassSurfaceModifier(shape: shape, interactive: interactive))
    }
}
