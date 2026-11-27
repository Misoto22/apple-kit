import SwiftUI

/// Environment-aware `ShapeStyle` resolving any semantic colour role from `\.misotoTheme`.
///
/// Usage:
/// ```swift
/// Text("Title")
///     .foregroundStyle(.misotoInk)
///     .background(.misotoPaper)
/// ```
public struct ThemeColorStyle: ShapeStyle, Hashable, Sendable {
    public enum Role: Sendable, Hashable {
        case paper
        case surface
        case ink
        case secondaryInk
        case tertiaryInk
        case hairline
        case scrim
        case accent
        case onAccent
        case skeleton
        case success
        case warning
        case error
        case glassSecondaryInk
        case glassTertiaryInk
        case glassWash
        case glassBand
    }

    public let role: Role

    public init(_ role: Role) {
        self.role = role
    }

    public func color(in theme: Theme) -> Color {
        switch role {
        case .paper: theme.colors.paper
        case .surface: theme.colors.surface
        case .ink: theme.colors.ink
        case .secondaryInk: theme.colors.secondaryInk
        case .tertiaryInk: theme.colors.tertiaryInk
        case .hairline: theme.colors.hairline
        case .scrim: theme.colors.scrim
        case .accent: theme.colors.accent
        case .onAccent: theme.colors.onAccent
        case .skeleton: theme.colors.skeleton
        case .success: theme.colors.success
        case .warning: theme.colors.warning
        case .error: theme.colors.error
        case .glassSecondaryInk: theme.colors.glass.secondaryInk
        case .glassTertiaryInk: theme.colors.glass.tertiaryInk
        case .glassWash: theme.colors.glass.wash
        case .glassBand: theme.colors.glass.band
        }
    }

    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        color(in: environment.misotoTheme).resolve(in: environment)
    }
}

extension ShapeStyle where Self == ThemeColorStyle {
    public static var misotoPaper: ThemeColorStyle { ThemeColorStyle(.paper) }
    public static var misotoSurface: ThemeColorStyle { ThemeColorStyle(.surface) }
    public static var misotoInk: ThemeColorStyle { ThemeColorStyle(.ink) }
    public static var misotoSecondaryInk: ThemeColorStyle { ThemeColorStyle(.secondaryInk) }
    public static var misotoTertiaryInk: ThemeColorStyle { ThemeColorStyle(.tertiaryInk) }
    public static var misotoHairline: ThemeColorStyle { ThemeColorStyle(.hairline) }
    public static var misotoScrim: ThemeColorStyle { ThemeColorStyle(.scrim) }
    public static var misotoAccent: ThemeColorStyle { ThemeColorStyle(.accent) }
    public static var misotoOnAccent: ThemeColorStyle { ThemeColorStyle(.onAccent) }
    public static var misotoSkeleton: ThemeColorStyle { ThemeColorStyle(.skeleton) }
    public static var misotoSuccess: ThemeColorStyle { ThemeColorStyle(.success) }
    public static var misotoWarning: ThemeColorStyle { ThemeColorStyle(.warning) }
    public static var misotoError: ThemeColorStyle { ThemeColorStyle(.error) }
    public static var misotoGlassSecondaryInk: ThemeColorStyle { ThemeColorStyle(.glassSecondaryInk) }
    public static var misotoGlassTertiaryInk: ThemeColorStyle { ThemeColorStyle(.glassTertiaryInk) }
    public static var misotoGlassWash: ThemeColorStyle { ThemeColorStyle(.glassWash) }
    public static var misotoGlassBand: ThemeColorStyle { ThemeColorStyle(.glassBand) }
}

private struct MisotoFontModifier: ViewModifier {
    let keyPath: KeyPath<Theme.Typography, FontRole> & Sendable
    @Environment(\.misotoTheme) private var theme

    func body(content: Content) -> some View {
        content.font(theme.typography[keyPath: keyPath].font)
    }
}

extension View {
    /// Applies a semantic typography role from `\.misotoTheme` without needing an explicit `@Environment(\.misotoTheme)`.
    public func misotoFont(_ keyPath: KeyPath<Theme.Typography, FontRole> & Sendable) -> some View {
        modifier(MisotoFontModifier(keyPath: keyPath))
    }
}
