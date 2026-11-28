import MisotoBehavior
import MisotoComponents
import MisotoLayout
import MisotoMotion
import MisotoTesting
import MisotoTheme
import SwiftUI

/// Interactive multi-brand component gallery supporting live switching of Theme, color scheme, Dynamic Type, and Reduce Motion.
public struct MisotoGalleryView: View {
    @State private var selectedBrandIndex = 0
    @State private var isDark = false
    @State private var useLargestText = false
    @State private var forceReduceMotion = false
    @State private var forceReduceTransparency = false
    @State private var toggleOn = true

    public init() {}

    private var activeBrand: (name: String, theme: Theme) {
        BrandThemeFixtures.allBrands[selectedBrandIndex]
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    controlsCard
                    MisotoGalleryShowcase(
                        brandName: activeBrand.name,
                        toggleOn: $toggleOn
                    )
                }
                .padding(16)
                .readableWidth()
            }
            .background(activeBrand.theme.colors.paper)
            .navigationTitle("AppleKit Gallery")
        }
        .misotoTheme(activeBrand.theme)
        .preferredColorScheme(isDark ? .dark : .light)
        .dynamicTypeSize(useLargestText ? .accessibility3 : .medium)
        .environment(\.forcesReduceMotion, forceReduceMotion)
        .environment(\.forcesReduceTransparency, forceReduceTransparency)
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Brand", selection: $selectedBrandIndex) {
                ForEach(BrandThemeFixtures.allBrands.indices, id: \.self) { index in
                    Text(BrandThemeFixtures.allBrands[index].name).tag(index)
                }
            }
            .pickerStyle(.segmented)
            Toggle("Dark Appearance", isOn: $isDark).toggleStyle(.misoto)
            Toggle("Accessibility Text Size", isOn: $useLargestText).toggleStyle(.misoto)
            Toggle("Force Reduce Motion", isOn: $forceReduceMotion).toggleStyle(.misoto)
            Toggle("Force Reduce Transparency", isOn: $forceReduceTransparency).toggleStyle(.misoto)
        }
        .padding(16)
        .background(
            activeBrand.theme.colors.surface,
            in: RoundedRectangle(cornerRadius: activeBrand.theme.radii.card, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: activeBrand.theme.radii.card, style: .continuous)
                .strokeBorder(activeBrand.theme.colors.hairline, lineWidth: activeBrand.theme.elevation.strokeWidth)
        )
    }
}

/// Deterministic showcase of retained shared primitives, layout rules, and glass surfaces.
public struct MisotoGalleryShowcase: View {
    public let brandName: String
    @Binding public var toggleOn: Bool

    @Environment(\.misotoTheme) private var theme

    public init(
        brandName: String,
        toggleOn: Binding<Bool> = .constant(true)
    ) {
        self.brandName = brandName
        self._toggleOn = toggleOn
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(brandName)
                    .font(theme.typography.title.font)
                    .foregroundStyle(theme.colors.ink)
                Text("Unified Primitives & Liquid Glass")
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.secondaryInk)
            }

            // Shared primitives with closed variants
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.md) {
                    MisotoSpinner()
                    MisotoProgress(value: 0.65)
                }
                Toggle("Shared Toggle Variant", isOn: $toggleOn)
                    .toggleStyle(.misoto)
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
                    .strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth)
            )

            // Layout primitives
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                EqualWidthRow(spacing: theme.spacing.sm) {
                    Text("Primary")
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.onAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.sm)
                        .background(theme.colors.accent, in: Capsule())
                    Text("Secondary")
                        .font(theme.typography.callout.font)
                        .foregroundStyle(theme.colors.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.sm)
                        .background(theme.colors.surface, in: Capsule())
                        .overlay(Capsule().strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
                }
                FlowLayout(spacing: theme.spacing.xs, lineSpacing: theme.spacing.xs, balancesRows: true) {
                    ForEach(["Balanced", "Flow", "Layout", "Tokens"], id: \.self) { label in
                        Text(label)
                            .font(theme.typography.caption.font)
                            .foregroundStyle(theme.colors.ink)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background(theme.colors.surface, in: Capsule())
                            .overlay(Capsule().strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
                    }
                }
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
                    .strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth)
            )

            // Liquid Glass & GlassInk surface sample (responds to Reduce Transparency)
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("SurfaceMaterial & GlassInk")
                    .font(theme.typography.headline.font)
                    .foregroundStyle(GlassInkStyle(plain: theme.colors.ink, glass: theme.colors.glass.secondaryInk))
                Text("Adapts cleanly under Reduce Transparency & High Contrast")
                    .font(theme.typography.caption.font)
                    .foregroundStyle(GlassInkStyle(plain: theme.colors.secondaryInk, glass: theme.colors.glass.tertiaryInk))
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GlassFill.wash(in: theme), in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous))
            .background(SurfaceMaterialBackground(lift: 0.35, in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)))
            .environment(\.standsOnGlass, true)
        }
    }
}
