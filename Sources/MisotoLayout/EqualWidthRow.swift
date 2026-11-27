import SwiftUI

/// Horizontal row layout that assigns every subview the exact same width and the row's maximum height.
public struct EqualWidthRow: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let count = CGFloat(subviews.count)
        let totalSpacing = spacing * max(0, count - 1)
        let availableWidth = proposal.width.map { max(0, ($0 - totalSpacing) / count) }
        let childProposal = ProposedViewSize(width: availableWidth, height: proposal.height)

        var maxSubWidth: CGFloat = 0
        var maxSubHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(childProposal)
            maxSubWidth = max(maxSubWidth, size.width)
            maxSubHeight = max(maxSubHeight, size.height)
        }
        let width = proposal.width ?? (maxSubWidth * count + totalSpacing)
        return CGSize(width: width, height: maxSubHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let count = CGFloat(subviews.count)
        let totalSpacing = spacing * max(0, count - 1)
        let itemWidth = max(0, (bounds.width - totalSpacing) / count)
        let childProposal = ProposedViewSize(width: itemWidth, height: bounds.height)

        var currentX = bounds.minX
        for subview in subviews {
            subview.place(
                at: CGPoint(x: currentX, y: bounds.midY),
                anchor: .leading,
                proposal: childProposal
            )
            currentX += itemWidth + spacing
        }
    }
}
