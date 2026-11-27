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
    @State private var segment = "One"
    @State private var toggleOn = true
    @State private var stepperValue = 2
    @State private var fieldText = "Sample input"
    @State private var searchText = ""

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
                        segment: $segment,
                        toggleOn: $toggleOn,
                        stepperValue: $stepperValue,
                        fieldText: $fieldText,
                        searchText: $searchText
                    )
                }
                .padding(16)
                .readableWidth()
            }
            .background(.misotoPaper)
            .navigationTitle("AppleKit Gallery")
        }
        .misotoTheme(activeBrand.theme)
        .preferredColorScheme(isDark ? .dark : .light)
        .dynamicTypeSize(useLargestText ? .accessibility3 : .medium)
        .environment(\.forcesReduceMotion, forceReduceMotion)
    }

    private var controlsCard: some View {
        MisotoCard {
            VStack(alignment: .leading, spacing: 12) {
                MisotoSegmentedControl(
                    options: Array(BrandThemeFixtures.allBrands.indices),
                    selection: $selectedBrandIndex,
                    title: { BrandThemeFixtures.allBrands[$0].name }
                )
                Toggle("Dark Appearance", isOn: $isDark).toggleStyle(.misoto)
                Toggle("Accessibility Text Size", isOn: $useLargestText).toggleStyle(.misoto)
                Toggle("Force Reduce Motion", isOn: $forceReduceMotion).toggleStyle(.misoto)
            }
        }
    }
}

/// Deterministic showcase of all 19 shared component categories, layout primitives, and glass surfaces.
public struct MisotoGalleryShowcase: View {
    public let brandName: String
    @Binding public var segment: String
    @Binding public var toggleOn: Bool
    @Binding public var stepperValue: Int
    @Binding public var fieldText: String
    @Binding public var searchText: String

    @Environment(\.misotoTheme) private var theme

    public init(
        brandName: String,
        segment: Binding<String> = .constant("One"),
        toggleOn: Binding<Bool> = .constant(true),
        stepperValue: Binding<Int> = .constant(2),
        fieldText: Binding<String> = .constant("Sample"),
        searchText: Binding<String> = .constant("")
    ) {
        self.brandName = brandName
        self._segment = segment
        self._toggleOn = toggleOn
        self._stepperValue = stepperValue
        self._fieldText = fieldText
        self._searchText = searchText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(brandName)
                .misotoFont(\.title)
                .foregroundStyle(.misotoInk)

            // Batch 1: Status & Feedback
            MisotoCard {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(spacing: theme.spacing.md) {
                        MisotoSpinner()
                        MisotoProgress(value: 0.65)
                    }
                    MisotoSkeletonRow()
                    MisotoBanner(tone: .info, title: "Unified Tokens", message: "SSOT variables resolved from Theme.")
                    MisotoToastCapsule(message: ToastMessage(text: "Saved changes", undo: {}), onUndo: {})
                    MisotoEmptyState(systemImage: "sparkles", title: "Empty State", message: "Shared across 4 brands", placement: .inline)
                    MisotoErrorState(title: "Sync Paused", message: "Retry available", severity: .warning, placement: .inline, retry: {})
                }
            }

            // Batch 2: Controls & Layout
            MisotoCard {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    EqualWidthRow {
                        Button("Primary") {}.buttonStyle(.misotoPrimary)
                        Button("Secondary") {}.buttonStyle(.misotoSecondary)
                    }
                    HStack(spacing: theme.spacing.sm) {
                        Button {} label: { Image(systemName: "xmark") }.buttonStyle(.misotoIcon)
                        Button("Text Action") {}.buttonStyle(.misotoText)
                        MisotoBusyButton("Busy", isBusy: false) {}
                    }
                    FlowLayout(spacing: theme.spacing.xs, lineSpacing: theme.spacing.xs) {
                        MisotoChip("Selected", systemImage: "checkmark", isSelected: true) {}
                        MisotoChip("Paper / Glass", isSelected: false) {}
                        MisotoChip("Tag")
                    }
                    Toggle("Switch / Check Variant", isOn: $toggleOn).toggleStyle(.misoto)
                    MisotoSegmentedControl(options: ["One", "Two", "Three"], selection: $segment, title: { $0 })
                    MisotoStepper("Count", value: $stepperValue, in: 0...10)
                    MisotoTextField("Field", text: $fieldText)
                    MisotoSearchField(text: $searchText)
                }
            }

            // Batch 3: Atomic Setting Row & Sheet Header
            MisotoCard {
                VStack(spacing: theme.spacing.xs) {
                    MisotoSheetHeader("Sheet Title", onCancel: {}, onSave: {})
                    MisotoSettingRow("Appearance", subtitle: LocalizedStringKey(brandName), systemImage: "paintbrush")
                }
            }

            // Liquid Glass surface sample
            HStack {
                Text("SurfaceMaterialBackground")
                    .misotoFont(\.callout)
                    .foregroundStyle(.misotoInk)
                    .padding(theme.spacing.md)
            }
            .frame(maxWidth: .infinity)
            .background(SurfaceMaterialBackground(lift: 0.35, in: RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)))
        }
    }
}
