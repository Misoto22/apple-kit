import MisotoTheme
import SwiftUI

extension EnvironmentValues {
    /// Forces Reduce Transparency on below for deterministic gallery and snapshot verification.
    @Entry public var forcesReduceTransparency: Bool = false
}

/// Whether transparency is reduced here: the system's setting, or `\.forcesReduceTransparency`.
@propertyWrapper
public struct ReduceTransparency: DynamicProperty {
    @Environment(\.accessibilityReduceTransparency) private var system
    @Environment(\.forcesReduceTransparency) private var forced

    public init() {}

    public var wrappedValue: Bool { system || forced }
}

/// The turn between Liquid Glass and an opaque surface: glass while a sheet or panel stands at a partial height, the
/// app's paper (``Theme/paper``) at full height, and between them, as a finger drags it, the paper coming in over the
/// glass with the lift.
///
/// Important pitfalls encoded here:
/// - Toggle glass effects only outside animations, otherwise content stays blurred.
/// - On iOS 26.0, a removed glass effect can continue drawing unless its backing view is hidden.
public enum SurfaceMaterial {
    /// The lifts over which the paper comes in: from the partial height (0) to just short of full (0.95).
    public static let paperLift: ClosedRange<CGFloat> = 0...0.95

    /// How much of the paper covers the glass at `lift`: 0 at the partial height and below, 1 at full, eased in (a cube)
    /// so the first half of a drag stays mostly glass.
    public static func paper(lift: CGFloat) -> CGFloat {
        let t = min(max((lift - paperLift.lowerBound) / (paperLift.upperBound - paperLift.lowerBound), 0), 1)
        return t * t * t
    }

    /// Whether a surface at `lift` still reads as glass: while less than half of the paper covers it.
    public static func isGlass(lift: CGFloat) -> Bool { paper(lift: lift) < 0.5 }

    /// `value` eased (smoothstep) from 0 at `start` to 1 at `end`, flat outside them.
    public static func ramp(_ value: CGFloat, from start: CGFloat, to end: CGFloat) -> CGFloat {
        let t = min(max((value - start) / (end - start), 0), 1)
        return t * t * (3 - 2 * t)
    }

    /// How far a system sheet stands lifted from its partial detent (`restTop`, 0) to `.large` (`fullTop`, 1).
    public static func systemLift(top: CGFloat, restTop: CGFloat, fullTop: CGFloat) -> CGFloat {
        guard restTop > fullTop else { return top <= fullTop ? 1 : 0 }
        return min(max((restTop - top) / (restTop - fullTop), 0), 1)
    }

    /// Where a system sheet's top stands at its partial detent before it has stood there once: half the window.
    public static func restTop(window: CGFloat) -> CGFloat { window / 2 }
    /// Where `.large` puts a sheet's top on an iPhone: a status bar and a step below the window's top.
    public static func fullTop(window: CGFloat) -> CGFloat { window * largeTopShare }
    public static let largeTopShare: CGFloat = 0.07

    /// Whether the presentation sits centered rather than anchored to the bottom of a phone sheet.
    /// Requires both `.regular` horizontal and `.regular` vertical size classes on iOS so landscape Pro Max iPhones
    /// (`regular × compact`) keep sheet drag semantics.
    public static func isCenteredSheet(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> Bool {
        #if os(iOS)
        horizontal == .regular && vertical == .regular
        #else
        true
        #endif
    }

    /// Whether the sheet configuration is always opaque paper regardless of drag lift.
    public static func isAlwaysPaper(
        detents: [PresentationDetent],
        overSheet: Bool = false,
        isCentered: Bool = false,
        reduceTransparency: Bool = false
    ) -> Bool {
        reduceTransparency || isCentered || overSheet || detents == [.large]
    }

    /// Whether a sheet at `selected` is paper outright: at `.large`, when `.large` is its only detent, when it stands
    /// over another sheet (`overSheet`), when presented centered (`isCentered`), or under Reduce Transparency.
    public static func isPaper(
        selected: PresentationDetent,
        detents: [PresentationDetent],
        overSheet: Bool = false,
        isCentered: Bool = false,
        reduceTransparency: Bool = false
    ) -> Bool {
        isAlwaysPaper(
            detents: detents,
            overSheet: overSheet,
            isCentered: isCentered,
            reduceTransparency: reduceTransparency
        ) || selected == .large
    }
}

extension EnvironmentValues {
    /// Whether the view stands on glass rather than paper, set by ``SwiftUI/View/surfaceMaterialSheet(detents:selection:overSheet:)``.
    @Entry public var standsOnGlass: Bool = false

    /// What a page inside a `surfaceMaterialSheet` navigation stack stands on; nil outside such a sheet.
    @Entry public var sheetPageGround: Color? = nil
}

/// A custom panel's ground at `lift`: regular glass with paper fading over it, falling back to solid paper under Reduce Transparency.
public struct SurfaceMaterialBackground<S: InsettableShape>: View {
    public let lift: CGFloat
    public let shape: S
    @Environment(\.misotoTheme) private var theme
    @ReduceTransparency private var reduceTransparency

    public init(lift: CGFloat, in shape: S) {
        self.lift = lift
        self.shape = shape
    }

    public var body: some View {
        if reduceTransparency {
            shape.fill(theme.colors.paper)
        } else {
            ZStack {
                Color.clear.glassEffect(.regular, in: shape)
                shape.fill(theme.colors.paper).opacity(SurfaceMaterial.paper(lift: lift))
            }
        }
    }
}

/// A presented sheet's material and detents: glass at partial detents on compact phones, solid paper at `.large`,
/// when stacked (`overSheet`), when presented centered on iPad regular width+height, or under Reduce Transparency.
private struct SurfaceMaterialSheet: ViewModifier {
    let detents: [PresentationDetent]
    let external: Binding<PresentationDetent>?
    let overSheet: Bool
    @Environment(\.misotoTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ReduceTransparency private var reduceTransparency
    @State private var own: PresentationDetent
    @State private var lift: CGFloat = 0
    @State private var restTop: CGFloat?
    @State private var fullTop: CGFloat?

    init(detents: [PresentationDetent], selection: Binding<PresentationDetent>?, overSheet: Bool) {
        self.detents = detents
        self.external = selection
        self.overSheet = overSheet
        _own = State(initialValue: detents.first ?? .large)
    }

    private var selected: Binding<PresentationDetent> { external ?? $own }
    private var isCentered: Bool {
        SurfaceMaterial.isCenteredSheet(horizontal: horizontalSizeClass, vertical: verticalSizeClass)
    }
    private var paperOnly: Bool {
        SurfaceMaterial.isAlwaysPaper(
            detents: detents,
            overSheet: overSheet,
            isCentered: isCentered,
            reduceTransparency: reduceTransparency
        )
    }
    private var rises: Bool { !paperOnly && detents.contains(.large) }
    private var paper: CGFloat { paperOnly ? 1 : rises ? SurfaceMaterial.paper(lift: lift) : 0 }

    func body(content: Content) -> some View {
        content
            .environment(\.standsOnGlass, paperOnly ? false : rises ? SurfaceMaterial.isGlass(lift: lift) : true)
            .environment(\.sheetPageGround, paperOnly ? theme.colors.paper : .clear)
            .modifier(Detents(detents: detents, selection: external ?? (detents.count > 1 ? $own : nil)))
            .background { if rises, paper > 0 { theme.colors.paper.opacity(paper).ignoresSafeArea() } }
            .onGeometryChange(for: TopEdge.self) { proxy in
                let frame = proxy.frame(in: .global)
                return TopEdge(top: frame.minY, window: frame.maxY)
            } action: { edge in
                guard rises else { return }
                if selected.wrappedValue == .large {
                    fullTop = min(fullTop ?? edge.top, edge.top)
                } else {
                    restTop = max(restTop ?? edge.top, edge.top)
                }
                let next = SurfaceMaterial.systemLift(
                    top: edge.top,
                    restTop: restTop ?? SurfaceMaterial.restTop(window: edge.window),
                    fullTop: fullTop ?? SurfaceMaterial.fullTop(window: edge.window)
                )
                let stepped = (next * 100).rounded() / 100
                if stepped != lift { lift = stepped }
            }
            .presentationBackground { if paperOnly { theme.colors.paper } }
    }
}

private struct TopEdge: Equatable {
    let top: CGFloat
    let window: CGFloat
}

private struct Detents: ViewModifier {
    let detents: [PresentationDetent]
    let selection: Binding<PresentationDetent>?

    @ViewBuilder func body(content: Content) -> some View {
        if let selection {
            content.presentationDetents(Set(detents), selection: selection)
        } else {
            content.presentationDetents(Set(detents))
        }
    }
}

extension View {
    /// The sheet's detents and material: glass at partial detents, paper at `.large`, stacked (`overSheet`),
    /// centered on iPad/macOS, or under Reduce Transparency. Replaces `presentationDetents` and `presentationBackground`.
    public func surfaceMaterialSheet(
        detents: [PresentationDetent] = [.large],
        selection: Binding<PresentationDetent>? = nil,
        overSheet: Bool = false
    ) -> some View {
        modifier(SurfaceMaterialSheet(detents: detents, selection: selection, overSheet: overSheet))
    }

    /// Background for a page inside a `surfaceMaterialSheet` navigation stack, preventing grey grouped flash during pushes.
    public func sheetPaperPage() -> some View {
        modifier(SheetPaperPage())
    }
}

private struct SheetPaperPage: ViewModifier {
    @Environment(\.sheetPageGround) private var ground

    @ViewBuilder func body(content: Content) -> some View {
        #if os(iOS)
        if let ground {
            content.containerBackground(ground, for: .navigation)
        } else {
            content
        }
        #else
        if let ground {
            content.background(ground)
        } else {
            content
        }
        #endif
    }
}
