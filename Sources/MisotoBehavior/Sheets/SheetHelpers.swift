import Foundation
import MisotoTheme
import SwiftUI

/// Localized dialog defaults bundled inside `MisotoBehavior`.
public enum MisotoBehaviorStrings {
    public static var resourceBundle: Bundle { .module }

    public static var discardChanges: String {
        String(localized: "discard_changes", defaultValue: "Discard Changes", bundle: .module)
    }

    public static var discardChangesTitle: String {
        String(localized: "discard_changes_title", defaultValue: "Discard changes?", bundle: .module)
    }

    public static var keepEditing: String {
        String(localized: "keep_editing", defaultValue: "Keep Editing", bundle: .module)
    }
}

/// Top scroll-edge policy for pages vs sheet forms vs map overlays.
public enum PageTopEdge: Sendable {
    /// Standard scrolling page under a bar: soft blur edge.
    case page
    /// Form inside a sheet: hard opaque edge so fields do not bleed behind close/save buttons.
    case form
    /// Content floating over a map: soft style, edge effect hidden.
    case overMap

    public var style: ScrollEdgeEffectStyle {
        switch self {
        case .page, .overMap: .soft
        case .form: .hard
        }
    }
}

private struct FittedSheet: ViewModifier {
    static let topBar: CGFloat = 64
    @State private var height: CGFloat = 0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let detents: [PresentationDetent] = if dynamicTypeSize.isAccessibilitySize {
            [.large]
        } else if height > 0 {
            [.height(height)]
        } else {
            [.medium]
        }
        content
            .onPreferenceChange(FittedSheetHeight.self) { measured in
                let fitted = measured + Self.topBar
                if measured > 0, abs(fitted - height) >= 1 { height = fitted }
            }
            .surfaceMaterialSheet(detents: detents)
    }
}

private struct FittedSheetHeight: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value += nextValue() }
}

private struct BottomActionBar<Bar: View>: ViewModifier {
    let bar: Bar
    var edge: ScrollEdgeEffectStyle
    var inset: CGFloat
    var maxWidth: CGFloat
    @State private var safeBottom: CGFloat = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.misotoTheme) private var theme

    private var drawnEdge: ScrollEdgeEffectStyle { typeSize.isAccessibilitySize ? .hard : edge }

    func body(content: Content) -> some View {
        content
            .scrollEdgeEffectStyle(drawnEdge, for: .bottom)
            .safeAreaBar(edge: .bottom) {
                bar
                    .frame(maxWidth: maxWidth)
                    .padding(.horizontal, inset)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, safeBottom > 0 ? 0 : theme.spacing.md)
            }
            .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { safeBottom = $0 }
    }
}

private struct DiscardChangesGuard: ViewModifier {
    let hasChanges: Bool
    @Binding var asking: Bool
    let title: Text
    let discardTitle: Text
    let keepEditingTitle: Text
    let discard: () -> Void

    func body(content: Content) -> some View {
        content
            .interactiveDismissDisabled(hasChanges)
            .confirmationDialog(title, isPresented: $asking, titleVisibility: .visible) {
                Button(role: .destructive, action: discard) { discardTitle }
                Button(role: .cancel) {} label: { keepEditingTitle }
            }
    }
}

/// Defers sheet `onDismiss` work to the next main-actor turn to avoid `SheetBridge` exclusivity crashes.
public enum SheetDismissal {
    public static func then(_ action: @escaping @MainActor () -> Void) -> () -> Void {
        { Task { @MainActor in action() } }
    }
}

extension View {
    /// Sets the scroll top-edge style for a page, form, or map overlay.
    public func pageTopEdge(_ edge: PageTopEdge = .page) -> some View {
        scrollEdgeEffectStyle(edge.style, for: .top)
            .scrollEdgeEffectHidden(edge == .overMap, for: .top)
    }

    /// Sizes a sheet to the height of views marked `.fitsSheet()`, collapsing to `.large` at accessibility text sizes.
    public func fittedSheet() -> some View {
        modifier(FittedSheet())
    }

    /// Marks this view's height to contribute to a `.fittedSheet()` detent.
    public func fitsSheet() -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(key: FittedSheetHeight.self, value: proxy.size.height)
            }
        }
    }

    /// Pins `bar` inside a bottom `safeAreaBar` with automatic accessibility edge hardening and readable width.
    public func bottomActionBar<Bar: View>(
        edge: ScrollEdgeEffectStyle = .soft,
        inset: CGFloat = 16,
        maxWidth: CGFloat = 640,
        @ViewBuilder _ bar: () -> Bar
    ) -> some View {
        modifier(BottomActionBar(bar: bar(), edge: edge, inset: inset, maxWidth: maxWidth))
    }

    /// Prevents swipe-to-dismiss while `hasChanges` is true and asks confirmation before discarding,
    /// defaulting to `MisotoBehavior`'s 6-language localized strings (`Bundle.module`).
    public func guardsUnsavedChanges(
        _ hasChanges: Bool,
        asking: Binding<Bool>,
        title: String? = nil,
        discardTitle: String? = nil,
        keepEditingTitle: String? = nil,
        discard: @escaping () -> Void
    ) -> some View {
        modifier(DiscardChangesGuard(
            hasChanges: hasChanges,
            asking: asking,
            title: Text(verbatim: title ?? MisotoBehaviorStrings.discardChangesTitle),
            discardTitle: Text(verbatim: discardTitle ?? MisotoBehaviorStrings.discardChanges),
            keepEditingTitle: Text(verbatim: keepEditingTitle ?? MisotoBehaviorStrings.keepEditing),
            discard: discard
        ))
    }

    /// Prevents swipe-to-dismiss while `hasChanges` is true with caller-localized `LocalizedStringKey` titles.
    @_disfavoredOverload
    public func guardsUnsavedChanges(
        _ hasChanges: Bool,
        asking: Binding<Bool>,
        title: LocalizedStringKey,
        discardTitle: LocalizedStringKey? = nil,
        keepEditingTitle: LocalizedStringKey? = nil,
        discard: @escaping () -> Void
    ) -> some View {
        modifier(DiscardChangesGuard(
            hasChanges: hasChanges,
            asking: asking,
            title: Text(title),
            discardTitle: discardTitle.map { Text($0) } ?? Text(verbatim: MisotoBehaviorStrings.discardChanges),
            keepEditingTitle: keepEditingTitle.map { Text($0) } ?? Text(verbatim: MisotoBehaviorStrings.keepEditing),
            discard: discard
        ))
    }

    /// Collapses partial sheet detents to `.large` when accessibility Dynamic Type sizes are active.
    public func accessibilityFullHeightSheetDetents(
        _ detents: [PresentationDetent],
        selection: Binding<PresentationDetent>? = nil
    ) -> some View {
        modifier(AccessibilityDetentsModifier(detents: detents, selection: selection))
    }

    /// Places the system close button in the cancellation toolbar slot on a sheet navigation root.
    public func sheetRootClose() -> some View {
        modifier(SheetRootCloseModifier())
    }
}

private struct SheetRootCloseModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) { dismiss() }
            }
        }
    }
}

private struct AccessibilityDetentsModifier: ViewModifier {
    let detents: [PresentationDetent]
    let selection: Binding<PresentationDetent>?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ViewBuilder func body(content: Content) -> some View {
        let effective = dynamicTypeSize.isAccessibilitySize ? [.large] : detents
        if let selection {
            content.presentationDetents(Set(effective), selection: selection)
        } else {
            content.presentationDetents(Set(effective))
        }
    }
}
