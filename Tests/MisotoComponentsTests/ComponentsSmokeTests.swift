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
                MisotoSpinner()
                MisotoSkeletonRow()
                MisotoProgress(value: 0.6)
                MisotoEmptyState(systemImage: "tray", title: "Empty", message: "Nothing here")
                MisotoErrorState(title: "Failed", retry: {})
                MisotoBanner(tone: .warning, title: "Notice")
                MisotoToastCapsule(message: ToastMessage(text: "Saved", undo: {}), onUndo: {})
                MisotoBusyButton("Submit", isBusy: false, action: {})
                MisotoChip("Filter", isSelected: true, action: {})
                MisotoCard { Text(name) }
                Toggle("Enabled", isOn: .constant(true)).toggleStyle(.misoto)
                MisotoSegmentedControl(options: ["A", "B"], selection: .constant("A"), title: { $0 })
                MisotoStepper("Count", value: .constant(2), in: 0...10)
                MisotoTextField("Name", text: .constant("Test"))
                MisotoSearchField(text: .constant(""))
                MisotoSettingRow("Account", subtitle: "Signed in", systemImage: "person")
                MisotoSheetHeader("Edit", onCancel: {}, onSave: {})
            }
            .frame(width: 360)
            .misotoTheme(theme)

            let renderer = ImageRenderer(content: view)
            #expect(renderer.cgImage != nil)
        }
    }
}
