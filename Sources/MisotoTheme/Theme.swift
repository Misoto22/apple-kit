import SwiftUI

/// Modular semantic roles mapped by each app once at its root with ``SwiftUI/View/misotoTheme(_:)``.
///
/// Motion curves live in `MisotoMotion` (unified across apps); `Theme` holds only brand-specific roles and closed
/// component variants. Each sub-struct provides sensible defaults on `.system` so adding a new role does not break apps.
public struct Theme: Sendable {
    public struct Colors: Sendable {
        public struct Glass: Sendable {
            public var secondaryInk: Color
            public var tertiaryInk: Color
            public var wash: Color
            public var band: Color

            public init(
                secondaryInk: Color = .secondary,
                tertiaryInk: Color = Color(ColorPair(RGBA(red: 0.45, green: 0.45, blue: 0.48, alpha: 0.9))),
                wash: Color = Color.primary.opacity(0.07),
                band: Color = Color.primary.opacity(0.14)
            ) {
                self.secondaryInk = secondaryInk
                self.tertiaryInk = tertiaryInk
                self.wash = wash
                self.band = band
            }

            public static let system = Glass()
        }

        public var paper: Color
        public var surface: Color
        public var ink: Color
        public var secondaryInk: Color
        public var tertiaryInk: Color
        public var hairline: Color
        public var scrim: Color
        public var accent: Color
        public var onAccent: Color
        public var skeleton: Color
        public var success: Color
        public var warning: Color
        public var error: Color
        public var glass: Glass

        public init(
            paper: Color = Color(ColorPair(light: 0xFFFFFF, dark: 0x000000)),
            surface: Color = Color(ColorPair(light: 0xF5F5F7, dark: 0x1C1C1E)),
            ink: Color = .primary,
            secondaryInk: Color = .secondary,
            tertiaryInk: Color = Color(ColorPair(RGBA(red: 0.5, green: 0.5, blue: 0.52, alpha: 0.8))),
            hairline: Color = Color(ColorPair(RGBA(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.25))),
            scrim: Color = Color(ColorPair(light: RGBA(hex: 0x000000, alpha: 0.2), dark: RGBA(hex: 0x000000, alpha: 0.5))),
            accent: Color = .accentColor,
            onAccent: Color = .white,
            skeleton: Color = Color(ColorPair(RGBA(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.12))),
            success: Color = .green,
            warning: Color = .orange,
            error: Color = .red,
            glass: Glass = .system
        ) {
            self.paper = paper
            self.surface = surface
            self.ink = ink
            self.secondaryInk = secondaryInk
            self.tertiaryInk = tertiaryInk
            self.hairline = hairline
            self.scrim = scrim
            self.accent = accent
            self.onAccent = onAccent
            self.skeleton = skeleton
            self.success = success
            self.warning = warning
            self.error = error
            self.glass = glass
        }

        public static let system = Colors()
    }

    public struct Typography: Sendable, Hashable {
        public var title: FontRole
        public var headline: FontRole
        public var body: FontRole
        public var callout: FontRole
        public var caption: FontRole
        public var mono: FontRole

        public init(
            title: FontRole = .system(.title2, weight: .semibold),
            headline: FontRole = .system(.headline, weight: .semibold),
            body: FontRole = .system(.body, weight: .regular),
            callout: FontRole = .system(.callout, weight: .regular),
            caption: FontRole = .system(.caption, weight: .regular),
            mono: FontRole = .system(.callout, design: .monospaced, weight: .regular)
        ) {
            self.title = title
            self.headline = headline
            self.body = body
            self.callout = callout
            self.caption = caption
            self.mono = mono
        }

        public static let system = Typography()
    }

    public struct Radii: Sendable, Hashable {
        public var small: CGFloat
        public var medium: CGFloat
        public var large: CGFloat
        public var control: CGFloat
        public var card: CGFloat

        public init(
            small: CGFloat = 8,
            medium: CGFloat = 12,
            large: CGFloat = 20,
            control: CGFloat = 12,
            card: CGFloat = 16
        ) {
            self.small = small
            self.medium = medium
            self.large = large
            self.control = control
            self.card = card
        }

        public static let system = Radii()
    }

    public struct Spacing: Sendable, Hashable {
        public var xs: CGFloat
        public var sm: CGFloat
        public var md: CGFloat
        public var lg: CGFloat
        public var xl: CGFloat

        public init(
            xs: CGFloat = 4,
            sm: CGFloat = 8,
            md: CGFloat = 16,
            lg: CGFloat = 24,
            xl: CGFloat = 32
        ) {
            self.xs = xs
            self.sm = sm
            self.md = md
            self.lg = lg
            self.xl = xl
        }

        public static let system = Spacing()
    }

    public struct Elevation: Sendable, Hashable {
        public var card: ShadowPair?
        public var floating: ShadowPair?
        public var strokeWidth: CGFloat

        public init(
            card: ShadowPair? = nil,
            floating: ShadowPair? = ShadowPair(
                light: ShadowToken(x: 0, y: 6, blur: 18, color: RGBA(hex: 0x000000, alpha: 0.12)),
                dark: ShadowToken(x: 0, y: 6, blur: 18, color: RGBA(hex: 0x000000, alpha: 0.40))
            ),
            strokeWidth: CGFloat = 1
        ) {
            self.card = card
            self.floating = floating
            self.strokeWidth = strokeWidth
        }

        public static let system = Elevation()
    }

    /// Closed value-type variants (at most 3 cases per component) injected once via `Theme` and overridable locally.
    public struct Variants: Sendable, Hashable {
        public enum SpinnerStyle: Sendable, Hashable { case arc, enso, markPulse }
        public enum ProgressStyle: Sendable, Hashable { case ring, bar }
        public enum ToggleVariant: Sendable, Hashable { case `switch`, check }

        public var spinner: SpinnerStyle
        public var progress: ProgressStyle
        public var toggle: ToggleVariant

        public init(
            spinner: SpinnerStyle = .arc,
            progress: ProgressStyle = .ring,
            toggle: ToggleVariant = .switch
        ) {
            self.spinner = spinner
            self.progress = progress
            self.toggle = toggle
        }

        public static let system = Variants()
    }

    public var colors: Colors
    public var typography: Typography
    public var radii: Radii
    public var spacing: Spacing
    public var elevation: Elevation
    public var variants: Variants

    public init(
        colors: Colors = .system,
        typography: Typography = .system,
        radii: Radii = .system,
        spacing: Spacing = .system,
        elevation: Elevation = .system,
        variants: Variants = .system
    ) {
        self.colors = colors
        self.typography = typography
        self.radii = radii
        self.spacing = spacing
        self.elevation = elevation
        self.variants = variants
    }

    // Convenience accessors preserving ergonomic shorthand across behavior & components.
    public var paper: Color { colors.paper }
    public var ink: Color { colors.ink }
    public var secondaryInk: Color { colors.secondaryInk }
    public var hairline: Color { colors.hairline }
    public var scrim: Color { colors.scrim }
    public var accent: Color { colors.accent }
    public var skeleton: Color { colors.skeleton }

    public static let system = Theme()
}

extension EnvironmentValues {
    /// The app's theme. Set it once at the root with ``SwiftUI/View/misotoTheme(_:)``.
    @Entry public var misotoTheme: Theme = .system
}

extension View {
    /// Hands the app's theme to every shared behaviour and component below.
    public func misotoTheme(_ theme: Theme) -> some View {
        environment(\.misotoTheme, theme)
    }
}
