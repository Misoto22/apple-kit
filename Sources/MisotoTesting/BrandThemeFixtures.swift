import MisotoTheme
import SwiftUI

/// Multi-brand Theme fixtures for gallery previews, snapshot tests, and component smoke tests.
public enum BrandThemeFixtures {
    public static let kioku = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xFAF9F6, dark: 0x141413)),
            surface: Color(ColorPair(light: 0xF2F0EA, dark: 0x1E1E1C)),
            ink: Color(ColorPair(light: 0x1E1D1A, dark: 0xF2F0EA)),
            secondaryInk: Color(ColorPair(light: 0x625F57, dark: 0xA8A49B)),
            accent: Color(ColorPair(light: 0x4A6B53, dark: 0x7BA386)),
            onAccent: .white
        ),
        typography: Theme.Typography(
            title: .system(.title2, design: .serif, weight: .semibold),
            headline: .system(.headline, design: .serif, weight: .semibold)
        ),
        variants: Theme.Variants(
            spinner: .arc,
            progress: .ring,
            toggle: .switch
        )
    )

    public static let revala = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xF8F7F4, dark: 0x141413)),
            surface: Color(ColorPair(light: 0xFBFAF7, dark: 0x1E1D1B)),
            ink: Color(ColorPair(light: 0x2A2927, dark: 0xF4F3EF)),
            secondaryInk: Color(ColorPair(light: 0x5A5750, dark: 0xABA79E)),
            accent: Color(ColorPair(light: 0x2A2927, dark: 0xF4F3EF)),
            onAccent: Color(ColorPair(light: 0xFBFAF7, dark: 0x141413)),
            glass: Theme.Colors.Glass(
                secondaryInk: Color(ColorPair(light: 0x5A5750, dark: 0xD2CEC5)),
                tertiaryInk: Color(ColorPair(light: 0x6F6B63, dark: 0xB8B3A9)),
                wash: Color.primary.opacity(0.07),
                band: Color.primary.opacity(0.14)
            )
        ),
        typography: Theme.Typography(
            title: .system(.title2, design: .serif, weight: .semibold),
            mono: .custom("Geist Mono", size: 14, relativeTo: .callout, weight: .medium)
        ),
        variants: Theme.Variants(
            spinner: .arc,
            progress: .bar,
            toggle: .switch
        )
    )

    public static let kura = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xF7F7F7, dark: 0x121212)),
            surface: Color(ColorPair(light: 0xFFFFFF, dark: 0x1C1C1C)),
            ink: Color(ColorPair(light: 0x171717, dark: 0xF5F5F5)),
            secondaryInk: Color(ColorPair(light: 0x5E5E5E, dark: 0xA3A3A3)),
            accent: Color(ColorPair(light: 0xD9581A, dark: 0xF06E2E)),
            onAccent: .white
        ),
        typography: Theme.Typography(
            mono: .custom("Martian Mono", size: 13, relativeTo: .callout, weight: .regular)
        ),
        variants: Theme.Variants(
            spinner: .markPulse,
            progress: .ring,
            toggle: .check
        )
    )

    public static let jade = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xF9FAF7, dark: 0x131614)),
            surface: Color(ColorPair(light: 0xF0F3EE, dark: 0x1C211E)),
            ink: Color(ColorPair(light: 0x1C241E, dark: 0xEFF3F0)),
            secondaryInk: Color(ColorPair(light: 0x55645A, dark: 0x9EAD9F)),
            accent: Color(ColorPair(light: 0x3D6848, dark: 0x6AA378)),
            onAccent: .white
        ),
        typography: Theme.Typography(
            title: .custom("Optima", size: 24, relativeTo: .title2, weight: .semibold)
        ),
        variants: Theme.Variants(
            spinner: .enso,
            progress: .bar,
            toggle: .switch
        )
    )

    public static let allBrands: [(name: String, theme: Theme)] = [
        ("Kioku", kioku),
        ("Revala", revala),
        ("Kura", kura),
        ("Jade", jade),
    ]
}
