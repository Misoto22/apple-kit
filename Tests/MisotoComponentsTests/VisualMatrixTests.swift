import MisotoGallery
import MisotoMotion
import MisotoTesting
import MisotoTheme
import SwiftUI
import Testing

@MainActor
struct VisualMatrixTests {
    @Test func gallerySnapshotsMatchAcrossBrandsAppearancesWidthsTextSizesAndReduceMotion() throws {
        struct MatrixCell {
            let label: String
            let scheme: ColorScheme
            let width: CGFloat
            let textSize: DynamicTypeSize
            let reduceMotion: Bool
        }

        let cells: [MatrixCell] = [
            MatrixCell(label: "light-phone", scheme: .light, width: 375, textSize: .medium, reduceMotion: false),
            MatrixCell(label: "dark-phone", scheme: .dark, width: 375, textSize: .medium, reduceMotion: false),
            MatrixCell(label: "ax5-reduced", scheme: .light, width: 375, textSize: .accessibility5, reduceMotion: true),
            MatrixCell(label: "ipad-regular", scheme: .light, width: 820, textSize: .medium, reduceMotion: false),
        ]

        for (brandName, theme) in BrandThemeFixtures.allBrands {
            for cell in cells {
                let view = MisotoGalleryShowcase(brandName: brandName)
                    .padding(16)
                    .frame(width: cell.width)
                    .background(.misotoPaper)
                    .misotoTheme(theme)
                    .environment(\.colorScheme, cell.scheme)
                    .environment(\.dynamicTypeSize, cell.textSize)
                    .environment(\.forcesReduceMotion, cell.reduceMotion)

                try SnapshotVerifier.assertSnapshot(
                    of: view,
                    named: "\(brandName.lowercased())-\(cell.label)"
                )
            }
        }
    }
}
