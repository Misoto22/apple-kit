import MisotoBehavior
import MisotoComponents
import MisotoLayout
import MisotoTesting
import MisotoTheme
import SwiftUI
import Testing

@MainActor
struct ComponentsSmokeTests {
    @Test func componentsRenderAcrossAllFourBrandFixtures() {
        for (name, theme) in BrandThemeFixtures.allBrands {
            let view = VStack {
                Text(name)
                    .misotoFont(\.headline)
                    .foregroundStyle(.misotoInk)
                MisotoSpinner()
                MisotoProgress(value: 0.6)
                Toggle("Enabled", isOn: .constant(true)).toggleStyle(.misoto)
                EqualWidthRow {
                    Text("A")
                    Text("B")
                }
                FlowLayout(balancesRows: true) {
                    Text("One")
                    Text("Two")
                    Text("Three")
                }
            }
            .frame(width: 360)
            .misotoTheme(theme)

            let renderer = ImageRenderer(content: view)
            #expect(renderer.cgImage != nil)
        }
    }

    @Test func localizedStringsAreNonEmpty() {
        #expect(!MisotoStrings.discardChangesTitle.isEmpty)
        #expect(!MisotoStrings.discardChanges.isEmpty)
        #expect(!MisotoStrings.keepEditing.isEmpty)
        #expect(!MisotoStrings.item(1, of: 3).isEmpty)
    }
}
