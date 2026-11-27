import MisotoGallery
import MisotoMotion
import MisotoTesting
import MisotoTheme
import SwiftUI
import Testing

@MainActor
struct VisualMatrixTests {
    @Test func galleryRendersAcrossBrandsAppearancesWidthsTextSizesAndReduceMotion() {
        let schemes: [ColorScheme] = [.light, .dark]
        let widths: [CGFloat] = [375, 820] // iPhone Compact & iPad Regular
        let textSizes: [DynamicTypeSize] = [.medium, .accessibility5]

        for (brandName, theme) in BrandThemeFixtures.allBrands {
            for scheme in schemes {
                for width in widths {
                    for textSize in textSizes {
                        for reduceMotion in [false, true] {
                            // Keep matrix crisp and bounded: check full cross on default size + largest size on light/dark.
                            if textSize == .accessibility5 && width == 820 && reduceMotion { continue }
                            let view = MisotoGalleryShowcase(brandName: brandName)
                                .padding(16)
                                .frame(width: width)
                                .background(.misotoPaper)
                                .misotoTheme(theme)
                                .environment(\.colorScheme, scheme)
                                .environment(\.dynamicTypeSize, textSize)
                                .environment(\.forcesReduceMotion, reduceMotion)

                            let renderer = ImageRenderer(content: view)
                            let image = renderer.cgImage
                            #expect(image != nil, "Failed rendering \(brandName) \(scheme) width=\(width) size=\(textSize) reduceMotion=\(reduceMotion)")
                            if let image {
                                #expect(image.width >= Int(width))
                                #expect(image.height > 100)
                            }
                        }
                    }
                }
            }
        }
    }
}
