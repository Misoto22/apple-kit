import SwiftUI

/// Adaptive multi-column grid for cards.
public struct CardGrid<Content: View>: View {
    private let minColumnWidth: CGFloat
    private let spacing: CGFloat
    private let content: Content

    public init(minColumnWidth: CGFloat = 280, spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.minColumnWidth = minColumnWidth
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minColumnWidth), spacing: spacing)],
            spacing: spacing
        ) {
            content
        }
    }
}

/// Expands a view's bounds around its center to at least `minSize × minSize` (`44 × 44 pt` by default) for touch hit
/// testing without altering visual layout size.
public struct HitArea: Shape, Sendable {
    public static let minimum: CGFloat = 44
    public var minSize: CGFloat

    public init(minSize: CGFloat = Self.minimum) {
        self.minSize = minSize
    }

    public func path(in rect: CGRect) -> Path {
        Path(
            rect.insetBy(
                dx: min(0, (rect.width - minSize) / 2),
                dy: min(0, (rect.height - minSize) / 2)
            )
        )
    }
}

/// Ensures at least a `minSize × minSize` accessible hit target via an expanded `contentShape` without altering layout size.
private struct HitTargetOutsetModifier: ViewModifier {
    let minSize: CGFloat

    func body(content: Content) -> some View {
        content.contentShape(HitArea(minSize: minSize))
    }
}

private struct ReadableWidthModifier: ViewModifier {
    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    /// Constrains content to a comfortable reading measure (default `640 pt`) centred in wider containers (iPad/Mac).
    public func readableWidth(maxWidth: CGFloat = 640) -> some View {
        modifier(ReadableWidthModifier(maxWidth: maxWidth))
    }

    /// Expands the interactive hit area to at least `minSize × minSize` (`44 pt` by default) without altering layout size.
    public func hitTargetOutset(minSize: CGFloat = HitArea.minimum) -> some View {
        modifier(HitTargetOutsetModifier(minSize: minSize))
    }
}
