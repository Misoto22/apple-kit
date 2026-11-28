import MisotoBehavior
import MisotoComponents
import MisotoGallery
import MisotoMotion
import MisotoTesting
import MisotoTheme
import SwiftUI
import Testing

@MainActor
struct VisualMatrixTests {
    @Test func gallerySnapshotsMatchAcrossBrandsAppearancesAccessibilityAndWidths() throws {
        struct MatrixCell {
            let label: String
            let scheme: ColorScheme
            let width: CGFloat
            let textSize: DynamicTypeSize
            let reduceMotion: Bool
            let reduceTransparency: Bool
        }

        let cells: [MatrixCell] = [
            MatrixCell(label: "light-phone", scheme: .light, width: 375, textSize: .medium, reduceMotion: false, reduceTransparency: false),
            MatrixCell(label: "dark-phone", scheme: .dark, width: 375, textSize: .medium, reduceMotion: false, reduceTransparency: false),
            MatrixCell(label: "ax5-light-reduced", scheme: .light, width: 375, textSize: .accessibility5, reduceMotion: true, reduceTransparency: false),
            MatrixCell(label: "ax5-dark-reduced", scheme: .dark, width: 375, textSize: .accessibility5, reduceMotion: true, reduceTransparency: false),
            MatrixCell(label: "reduce-transparency", scheme: .light, width: 375, textSize: .medium, reduceMotion: false, reduceTransparency: true),
            MatrixCell(label: "ipad-regular", scheme: .light, width: 820, textSize: .medium, reduceMotion: false, reduceTransparency: false),
        ]

        for (brandName, theme) in BrandThemeFixtures.allBrands {
            for cell in cells {
                let view = MisotoGalleryShowcase(brandName: brandName)
                    .padding(16)
                    .frame(width: cell.width)
                    .background(theme.colors.paper)
                    .misotoTheme(theme)
                    .environment(\.colorScheme, cell.scheme)
                    .environment(\.dynamicTypeSize, cell.textSize)
                    .environment(\.forcesReduceMotion, cell.reduceMotion)
                    .environment(\.forcesReduceTransparency, cell.reduceTransparency)

                try SnapshotVerifier.assertSnapshot(
                    of: view,
                    named: "\(brandName.lowercased())-\(cell.label)"
                )
            }
        }
    }

    @Test func tightPrimitiveSnapshotsDetectMissingOrShiftedComponents() throws {
        for (brandName, theme) in BrandThemeFixtures.allBrands {
            let slug = brandName.lowercased()

            let spinner = MisotoSpinner()
                .padding(8)
                .frame(width: 36, height: 36)
                .background(theme.colors.paper)
                .misotoTheme(theme)
                .environment(\.colorScheme, .light)
            try SnapshotVerifier.assertSnapshot(of: spinner, named: "\(slug)-component-spinner")

            let progress = MisotoProgress(value: 0.65)
                .padding(8)
                .frame(width: 72, height: 36)
                .background(theme.colors.paper)
                .misotoTheme(theme)
                .environment(\.colorScheme, .light)
            try SnapshotVerifier.assertSnapshot(of: progress, named: "\(slug)-component-progress")

            let toggleOn = Toggle("Setting", isOn: .constant(true))
                .toggleStyle(.misoto)
                .padding(8)
                .frame(width: 180, height: 44)
                .background(theme.colors.paper)
                .misotoTheme(theme)
                .environment(\.colorScheme, .light)
            try SnapshotVerifier.assertSnapshot(of: toggleOn, named: "\(slug)-component-toggle-on")

            let toggleOff = Toggle("Setting", isOn: .constant(false))
                .toggleStyle(.misoto)
                .padding(8)
                .frame(width: 180, height: 44)
                .background(theme.colors.paper)
                .misotoTheme(theme)
                .environment(\.colorScheme, .light)
            try SnapshotVerifier.assertSnapshot(of: toggleOff, named: "\(slug)-component-toggle-off")

            let toggleDisabled = Toggle("Setting", isOn: .constant(true))
                .toggleStyle(.misoto)
                .disabled(true)
                .padding(8)
                .frame(width: 180, height: 44)
                .background(theme.colors.paper)
                .misotoTheme(theme)
                .environment(\.colorScheme, .light)
            try SnapshotVerifier.assertSnapshot(of: toggleDisabled, named: "\(slug)-component-toggle-disabled")
        }
    }
}
