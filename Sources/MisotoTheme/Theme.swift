import SwiftUI

/// The roles a shared behaviour reads, which each app fills from its own brand once, at its root.
///
/// The names are shared; the values never are (docs/decisions/0002). A role here exists because a behaviour in
/// MisotoBehavior needs it: a glass surface settles into `paper`, a privacy cover is `paper` with the app's mark in
/// `secondaryInk`, a loading block breathes in `skeleton`. An app's own components keep reading the app's own tokens.
public struct Theme: Sendable {
    /// The opaque ground: what a glass surface turns into at full height, and what a privacy cover shows.
    public var paper: Color
    /// Primary text and marks.
    public var ink: Color
    /// Secondary text and marks.
    public var secondaryInk: Color
    /// Separators and outlines.
    public var hairline: Color
    /// What dims the page behind a presented layer.
    public var scrim: Color
    /// The app's accent.
    public var accent: Color
    /// A loading block's wash.
    public var skeleton: Color
    /// The app's curves.
    public var motion: MotionSet

    public init(
        paper: Color,
        ink: Color,
        secondaryInk: Color,
        hairline: Color,
        scrim: Color,
        accent: Color,
        skeleton: Color,
        motion: MotionSet
    ) {
        self.paper = paper
        self.ink = ink
        self.secondaryInk = secondaryInk
        self.hairline = hairline
        self.scrim = scrim
        self.accent = accent
        self.skeleton = skeleton
        self.motion = motion
    }

    /// The system's own colours and curves: what a view sees before an app sets its theme, and in previews.
    public static let system = Theme(
        paper: Color(ColorPair(light: 0xFFFFFF, dark: 0x000000)),
        ink: .primary,
        secondaryInk: .secondary,
        hairline: Color(ColorPair(RGBA(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.25))),
        scrim: Color(ColorPair(light: RGBA(hex: 0x000000, alpha: 0.2), dark: RGBA(hex: 0x000000, alpha: 0.5))),
        accent: .accentColor,
        skeleton: Color(ColorPair(RGBA(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.12))),
        motion: .system
    )
}

/// An app's curves, by what moves. Each app keeps its own character: kioku's springs, Revala's standard bezier,
/// Jade's no-spring rule. A shared behaviour asks for the role, never for a curve.
public struct MotionSet: Sendable {
    /// Something under the finger: a press, a selection, a switch.
    public var quick: Animation
    /// A block of content arriving, leaving or changing size; a sheet or a surface settling.
    public var standard: Animation
    /// One cycle of a loading block's breath; the behaviour repeats it.
    public var breath: Animation

    public init(quick: Animation, standard: Animation, breath: Animation) {
        self.quick = quick
        self.standard = standard
        self.breath = breath
    }

    public static let system = MotionSet(
        quick: .snappy(duration: 0.25),
        standard: .smooth(duration: 0.35),
        breath: .easeInOut(duration: 1.1)
    )
}

extension EnvironmentValues {
    /// The app's theme. Set it once at the root with ``SwiftUI/View/misotoTheme(_:)``.
    @Entry public var misotoTheme: Theme = .system
}

extension View {
    /// Hands the app's theme to every shared behaviour below.
    public func misotoTheme(_ theme: Theme) -> some View {
        environment(\.misotoTheme, theme)
    }
}
