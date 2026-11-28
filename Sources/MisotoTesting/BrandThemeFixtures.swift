import MisotoTheme
import SwiftUI

/// Multi-brand Theme fixtures aligned with each brand's authoritative color & typography tokens for gallery previews
/// and visual snapshot verification.
///
/// Provenance:
/// - `kioku`: `Misoto22/kioku-ios` (`Sources/Shared/Palette.swift`, `Sources/Shared/Accent.swift`, `KiokuTheme.swift`)
/// - `revala`: `revala-app/revala-brand` (`generated/tokens.json` via `@revala-app/design-tokens`)
/// - `kura`: `kura-casa/kura-brand` (`Vendor/kura-brand/KuraBrand.swift`)
/// - `jade`: `jade-the-cat/jade-brand` (`Packages/JadeKit/Sources/JadeDesign/Generated/DesignTokens.swift`, `DSTheme.swift`)
public enum BrandThemeFixtures {
    public static let kioku = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xF9F8F4, dark: 0x131211)),
            surface: Color(ColorPair(light: 0xF9F8F4, dark: 0x2E2D2B)),
            ink: Color(ColorPair(light: 0x1C1A17, dark: 0xF0EDE8)),
            secondaryInk: Color(ColorPair(
                light: RGBA(hex: 0x1C1A17, alpha: 0.62),
                dark: RGBA(hex: 0xF0EDE8, alpha: 0.62)
            )),
            tertiaryInk: Color(ColorPair(
                light: RGBA(hex: 0x1C1A17, alpha: 0.35),
                dark: RGBA(hex: 0xF0EDE8, alpha: 0.35)
            )),
            hairline: Color(ColorPair(
                light: RGBA(hex: 0x1C1A17, alpha: 0.14),
                dark: RGBA(hex: 0xF0EDE8, alpha: 0.14)
            )),
            scrim: Color(ColorPair(
                light: RGBA(hex: 0x1C1A17, alpha: 0.20),
                dark: RGBA(hex: 0x131211, alpha: 0.55)
            )),
            accent: Color(ColorPair(
                light: RGBA(hex: 0x6B856B),
                dark: RGBA(hex: 0x6B856B),
                lightIncreasedContrast: RGBA(hex: 0x5F785F),
                darkIncreasedContrast: RGBA(hex: 0x6B856B)
            )),
            onAccent: Color(ColorPair(light: 0xF9F8F4, dark: 0x131211)),
            success: Color(ColorPair(light: 0x5F785F, dark: 0x6B856B)),
            warning: Color(ColorPair(light: 0x926A32, dark: 0xA88047)),
            error: Color(ColorPair(light: 0x9E5745, dark: 0xB46A57))
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
            paper: Color(ColorPair(light: 0xF8F7F4, dark: 0x1A1A18)),
            surface: Color(ColorPair(light: 0xFBFAF7, dark: 0x21211F)),
            ink: Color(ColorPair(light: 0x2A2927, dark: 0xE6E3DB)),
            secondaryInk: Color(ColorPair(
                light: RGBA(hex: 0x5A5750),
                dark: RGBA(hex: 0xABA69B),
                lightIncreasedContrast: RGBA(hex: 0x45423C),
                darkIncreasedContrast: RGBA(hex: 0xC9C5BB)
            )),
            tertiaryInk: Color(ColorPair(
                light: RGBA(hex: 0x6F6B63),
                dark: RGBA(hex: 0x9A958A),
                lightIncreasedContrast: RGBA(hex: 0x524F49),
                darkIncreasedContrast: RGBA(hex: 0xB5B0A5)
            )),
            hairline: Color(ColorPair(
                light: RGBA(hex: 0xD9D6CE),
                dark: RGBA(hex: 0x3A3935),
                lightIncreasedContrast: RGBA(hex: 0x8F8A7F),
                darkIncreasedContrast: RGBA(hex: 0x77736A)
            )),
            accent: Color(ColorPair(light: 0x2A2927, dark: 0xE6E3DB)),
            onAccent: Color(ColorPair(light: 0xFBFAF7, dark: 0x21211F)),
            skeleton: Color(ColorPair(light: 0xEFEEE9, dark: 0x2A2927)),
            success: Color(ColorPair(light: 0x23703F, dark: 0x4CAE70)),
            warning: Color(ColorPair(light: 0x9A6700, dark: 0xF0C44C)),
            error: Color(ColorPair(light: 0xA82A20, dark: 0xFF9A92)),
            glass: Theme.Colors.Glass(
                secondaryInk: Color(ColorPair(light: 0x5A5750, dark: 0xDCD8CE)),
                tertiaryInk: Color(ColorPair(light: 0x6F6B63, dark: 0xD5D1C7)),
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
            surface: Color(ColorPair(light: 0xFFFFFF, dark: 0x1E1E1E)),
            ink: Color(ColorPair(light: 0x1B1B1B, dark: 0xEDEDED)),
            secondaryInk: Color(ColorPair(light: 0x6E6E6E, dark: 0x999999)),
            hairline: Color(ColorPair(light: 0xE5E5E5, dark: 0x2E2E2E)),
            accent: Color(ColorPair(light: 0xC2410C, dark: 0xF0874D)),
            onAccent: Color(ColorPair(light: 0xF7F7F7, dark: 0x121212)),
            skeleton: Color(ColorPair(light: 0xEFEFEF, dark: 0x2A2A2A)),
            success: Color(ColorPair(light: 0x2F7D4F, dark: 0x5BBF85)),
            warning: Color(ColorPair(light: 0xC2410C, dark: 0xF0874D)),
            error: Color(ColorPair(light: 0xC4291F, dark: 0xFF6961))
        ),
        typography: Theme.Typography(
            title: .system(.title2, weight: .regular),
            headline: .system(.headline, weight: .medium),
            body: .system(.body, weight: .regular),
            callout: .system(.subheadline, weight: .regular),
            caption: .system(.footnote, weight: .regular),
            mono: .custom("Martian Mono", size: 13, relativeTo: .subheadline, weight: .medium)
        ),
        variants: Theme.Variants(
            spinner: .markPulse,
            progress: .ring,
            toggle: .check
        )
    )

    public static let jade = Theme(
        colors: Theme.Colors(
            paper: Color(ColorPair(light: 0xFBFAF6, dark: 0x262523)),
            surface: Color(ColorPair(light: 0xF8F7F2, dark: 0x2A2927)),
            ink: Color(ColorPair(light: 0x4A4843, dark: 0xE7E4DC)),
            secondaryInk: Color(ColorPair(light: 0x706C64, dark: 0xA29E95)),
            tertiaryInk: Color(ColorPair(light: 0x8C887F, dark: 0x7B776F)),
            hairline: Color(ColorPair(
                light: RGBA(hex: 0x4A4843, alpha: 0.09),
                dark: RGBA(hex: 0xE7E4DC, alpha: 0.09)
            )),
            scrim: Color(ColorPair(
                light: RGBA(hex: 0xFBFAF6, alpha: 0.72),
                dark: RGBA(hex: 0x262523, alpha: 0.72)
            )),
            accent: Color(ColorPair(light: 0x4E6F60, dark: 0xA3CBBB)),
            onAccent: Color(ColorPair(light: 0xFFFFFF, dark: 0x1E2622)),
            skeleton: Color(ColorPair(
                light: RGBA(hex: 0xF3F1EB, alpha: 1.0),
                dark: RGBA(hex: 0xE7E4DC, alpha: 0.07)
            )),
            success: Color(ColorPair(light: 0x4E6F60, dark: 0xA3CBBB)),
            warning: Color(ColorPair(light: 0xAC523C, dark: 0xE39580)),
            error: Color(ColorPair(light: 0xAC523C, dark: 0xE39580))
        ),
        typography: Theme.Typography(
            title: .custom("Optima", size: 24, relativeTo: .title2, weight: .semibold),
            headline: .system(.headline, weight: .regular),
            body: .system(.body, weight: .light),
            callout: .system(.callout, weight: .light),
            caption: .system(.caption, weight: .regular)
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
