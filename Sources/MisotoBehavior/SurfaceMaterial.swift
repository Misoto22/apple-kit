import SwiftUI

/// The turn between Liquid Glass and an opaque surface: glass while a sheet or panel stands at a partial height, the
/// app's paper (``Theme/paper``) at full height, and between them, as a finger drags it, the paper coming in over the
/// glass with the lift.
///
/// From revala-ios's `SheetMaterial` (owner, 2026-11-23/24: the whole drag turns the glass to paper, slowly at first
/// and faster towards the top). The math is pure, so a UIKit sheet controller and a SwiftUI sheet read the same curve.
public enum SurfaceMaterial {
    /// The lifts over which the paper comes in: from the partial height (0) to just short of full (0.95).
    public static let paperLift: ClosedRange<CGFloat> = 0...0.95

    /// How much of the paper covers the glass at `lift`: 0 at the partial height and below, 1 at full, eased in (a cube)
    /// so the first half of a drag stays mostly glass.
    public static func paper(lift: CGFloat) -> CGFloat {
        let t = min(max((lift - paperLift.lowerBound) / (paperLift.upperBound - paperLift.lowerBound), 0), 1)
        return t * t * t
    }

    /// Whether a surface at `lift` still reads as glass: while less than half of the paper covers it. What stands on it
    /// takes the glass inks until then.
    public static func isGlass(lift: CGFloat) -> Bool { paper(lift: lift) < 0.5 }

    /// `value` eased (smoothstep) from 0 at `start` to 1 at `end`, flat outside them.
    public static func ramp(_ value: CGFloat, from start: CGFloat, to end: CGFloat) -> CGFloat {
        let t = min(max((value - start) / (end - start), 0), 1)
        return t * t * (3 - 2 * t)
    }

    /// How far a system sheet stands lifted from its partial detent (`restTop`, 0) to `.large` (`fullTop`, 1), from where
    /// its top edge is now.
    public static func systemLift(top: CGFloat, restTop: CGFloat, fullTop: CGFloat) -> CGFloat {
        guard restTop > fullTop else { return top <= fullTop ? 1 : 0 }
        return min(max((restTop - top) / (restTop - fullTop), 0), 1)
    }

    /// Where a system sheet's top stands at its partial detent before it has stood there once: half the window.
    public static func restTop(window: CGFloat) -> CGFloat { window / 2 }
    /// Where `.large` puts a sheet's top on a phone: a status bar and a step below the window's top.
    public static func fullTop(window: CGFloat) -> CGFloat { window * largeTopShare }
    public static let largeTopShare: CGFloat = 0.07

    /// Whether a sheet at `selected` is paper outright: at `.large`, when `.large` is its only detent, or when it stands on
    /// another sheet (glass over a sheet blurs that sheet's rows and shows two rims).
    public static func isPaper(selected: PresentationDetent, detents: [PresentationDetent], overSheet: Bool = false) -> Bool {
        overSheet || selected == .large || detents == [.large]
    }
}

extension EnvironmentValues {
    /// Whether the view stands on glass rather than paper, set by ``SwiftUI/View/surfaceMaterialSheet(detents:selection:overSheet:)``.
    /// An app maps it to its own glass inks.
    @Entry public var standsOnGlass: Bool = false
}

/// A custom panel's ground at `lift`: the system's regular glass, with the app's paper over it by how far the panel is
/// pulled up. Reduce Transparency is the system glass's own business: it frosts itself.
@available(iOS 26, macOS 26, *)
public struct SurfaceMaterialBackground<S: InsettableShape>: View {
    public let lift: CGFloat
    public let shape: S
    @Environment(\.misotoTheme) private var theme

    public init(lift: CGFloat, in shape: S) {
        self.lift = lift
        self.shape = shape
    }

    public var body: some View {
        ZStack {
            Color.clear.glassEffect(.regular, in: shape)
            shape.fill(theme.paper).opacity(SurfaceMaterial.paper(lift: lift))
        }
    }
}

/// A presented sheet's material and detents: the system's glass at a partial detent, the paper at `.large`, and between
/// them, as the sheet is dragged, the paper coming in with its lift.
@available(iOS 26, macOS 26, *)
private struct SurfaceMaterialSheet: ViewModifier {
    let detents: [PresentationDetent]
    let external: Binding<PresentationDetent>?
    let overSheet: Bool
    @Environment(\.misotoTheme) private var theme
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
    private var paperOnly: Bool { overSheet || detents == [.large] }
    private var rises: Bool { !paperOnly && detents.contains(.large) }
    private var paper: CGFloat { paperOnly ? 1 : rises ? SurfaceMaterial.paper(lift: lift) : 0 }

    func body(content: Content) -> some View {
        content
            .environment(\.standsOnGlass, paperOnly ? false : rises ? SurfaceMaterial.isGlass(lift: lift) : true)
            .modifier(Detents(detents: detents, selection: external ?? (detents.count > 1 ? $own : nil)))
            .background { if rises, paper > 0 { theme.paper.opacity(paper).ignoresSafeArea() } }
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
                // In hundredths, so a frame that moves the top by a fraction of a point leaves the sheet as it is.
                let stepped = (next * 100).rounded() / 100
                if stepped != lift { lift = stepped }
            }
            .presentationBackground { if paperOnly { theme.paper } }
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

@available(iOS 26, macOS 26, *)
extension View {
    /// The sheet's detents and its one material: glass at every partial detent, the theme's paper at `.large`, the paper
    /// coming in as it is dragged between them. Replaces `presentationDetents` and `presentationBackground`. Sets
    /// `\.standsOnGlass` for what the sheet holds. `overSheet`: a sheet presented from another sheet is paper throughout.
    public func surfaceMaterialSheet(
        detents: [PresentationDetent] = [.large],
        selection: Binding<PresentationDetent>? = nil,
        overSheet: Bool = false
    ) -> some View {
        modifier(SurfaceMaterialSheet(detents: detents, selection: selection, overSheet: overSheet))
    }
}
