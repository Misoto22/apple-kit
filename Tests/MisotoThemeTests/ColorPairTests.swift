import MisotoTheme
import SwiftUI
import Testing

struct ColorPairTests {
    @Test func hexSplitsIntoChannels() {
        let value = RGBA(hex: 0xC2410C)
        #expect(abs(value.red - 194.0 / 255) < 1e-9)
        #expect(abs(value.green - 65.0 / 255) < 1e-9)
        #expect(abs(value.blue - 12.0 / 255) < 1e-9)
        #expect(value.alpha == 1)
    }

    @Test func resolvesEachAppearance() {
        let pair = ColorPair(
            light: RGBA(hex: 0x111111),
            dark: RGBA(hex: 0xEEEEEE),
            lightIncreasedContrast: RGBA(hex: 0x000000),
            darkIncreasedContrast: nil
        )
        #expect(pair.resolve(dark: false, increasedContrast: false) == RGBA(hex: 0x111111))
        #expect(pair.resolve(dark: true, increasedContrast: false) == RGBA(hex: 0xEEEEEE))
        #expect(pair.resolve(dark: false, increasedContrast: true) == RGBA(hex: 0x000000))
        #expect(pair.resolve(dark: true, increasedContrast: true) == RGBA(hex: 0xEEEEEE), "falls back to the plain dark value")
    }

    @Test func opacityScalesEveryForm() {
        let pair = ColorPair(light: RGBA(hex: 0, alpha: 0.5), dark: RGBA(hex: 0), lightIncreasedContrast: RGBA(hex: 0))
        let faded = pair.opacity(0.5)
        #expect(faded.light.alpha == 0.25)
        #expect(faded.dark.alpha == 0.5)
        #expect(faded.lightIncreasedContrast?.alpha == 0.5)
        #expect(faded.darkIncreasedContrast == nil)
    }

    #if canImport(UIKit) && !os(watchOS)
    @MainActor
    @Test func uiColorFollowsTheTraits() {
        let color = UIColor(ColorPair(light: 0xFFFFFF, dark: 0x000000))
        var red: CGFloat = -1
        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(abs(red - 0) < 0.001)
        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(abs(red - 1) < 0.001)
        let contrast = UIColor(ColorPair(
            light: RGBA(hex: 0x808080), dark: RGBA(hex: 0x808080), lightIncreasedContrast: RGBA(hex: 0x000000)
        ))
        let high = UITraitCollection { traits in
            traits.userInterfaceStyle = .light
            traits.accessibilityContrast = .high
        }
        contrast.resolvedColor(with: high).getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(abs(red - 0) < 0.001)
    }

    @Test func uiColorResolvesOffTheMainThread() async {
        let color = UIColor(ColorPair(light: 0xFFFFFF, dark: 0x000000))
        let white = await Task.detached {
            var red: CGFloat = -1
            color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).getRed(&red, green: nil, blue: nil, alpha: nil)
            return red
        }.value
        #expect(abs(white - 0) < 0.001)
    }
    #endif
}

@MainActor
struct ThemeTests {
    @Test func theSystemThemeIsTheDefaultAndSupportsLocalOverrides() {
        var values = EnvironmentValues()
        #expect(values.misotoTheme.radii == Theme.system.radii)
        #expect(values.misotoTheme.variants == Theme.system.variants)
        values.misotoTheme.colors.accent = .red
        values.misotoTheme.variants.card = .glass
        #expect(values.misotoTheme.accent == .red)
        #expect(values.misotoTheme.variants.card == .glass)
    }

    @Test func shadowPairResolvesByColorScheme() {
        let light = ShadowToken(x: 0, y: 2, blur: 4, color: RGBA(hex: 0x000000, alpha: 0.1))
        let dark = ShadowToken(x: 0, y: 2, blur: 4, color: RGBA(hex: 0x000000, alpha: 0.4))
        let pair = ShadowPair(light: light, dark: dark)
        #expect(pair.resolve(for: .light) == light)
        #expect(pair.resolve(for: .dark) == dark)
    }

    @Test func themeColorStyleResolvesFromEnvironmentAndModifiersCompile() {
        var env = EnvironmentValues()
        let customAccent = Color(.sRGB, red: 0.2, green: 0.6, blue: 0.4, opacity: 1)
        env.misotoTheme.colors.accent = customAccent

        let resolved = ThemeColorStyle.misotoAccent.resolve(in: env)
        #expect(abs(Double(resolved.red) - 0.2) < 0.01)
        #expect(abs(Double(resolved.green) - 0.6) < 0.01)

        let view = Text("SSOT")
            .misotoFont(\.headline)
            .foregroundStyle(.misotoInk)
            .background(.misotoPaper)
        let renderer = ImageRenderer(content: view.misotoTheme(env.misotoTheme))
        #expect(renderer.cgImage != nil)
    }
}
