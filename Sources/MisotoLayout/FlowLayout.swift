import SwiftUI

/// Wrapping flow layout for chips, tags, and badges, with optional balanced row distribution
/// and wide-child wrapping within container width.
public struct FlowLayout: Layout {
    public var spacing: CGFloat
    public var lineSpacing: CGFloat
    public var balancesRows: Bool

    public init(spacing: CGFloat = 8, lineSpacing: CGFloat? = nil, balancesRows: Bool = false) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing ?? spacing
        self.balancesRows = balancesRows
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else {
            return CGSize(width: proposal.width ?? 0, height: 0)
        }
        let maxWidth = proposal.width ?? .infinity
        let sizes = subviews.map { fittedSize(of: $0, maxWidth: maxWidth) }
        let rows = Self.arrange(sizes: sizes, maxWidth: maxWidth, spacing: spacing, balancesRows: balancesRows)

        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        for (rowIndex, row) in rows.enumerated() {
            var rowWidth: CGFloat = 0
            var rowHeight: CGFloat = 0
            for (pos, itemIndex) in row.enumerated() {
                if pos > 0 { rowWidth += spacing }
                rowWidth += sizes[itemIndex].width
                rowHeight = max(rowHeight, sizes[itemIndex].height)
            }
            totalWidth = max(totalWidth, rowWidth)
            if rowIndex > 0 { totalHeight += lineSpacing }
            totalHeight += rowHeight
        }

        return CGSize(
            width: proposal.width ?? totalWidth,
            height: totalHeight
        )
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        // Measure and place at the offered width when it equals/exceeds rounded `bounds.width`,
        // preventing sub-pixel rounding from pushing the trailing item onto an unexpected extra line.
        let layoutWidth = proposal.width.map { max($0, bounds.width) } ?? bounds.width
        let proposals = subviews.map { fittedProposal(for: $0, maxWidth: layoutWidth) }
        let sizes = zip(subviews, proposals).map { $0.sizeThatFits($1) }
        let rows = Self.arrange(sizes: sizes, maxWidth: layoutWidth, spacing: spacing, balancesRows: balancesRows)

        var y = bounds.minY
        for (rowIndex, row) in rows.enumerated() {
            if rowIndex > 0 { y += lineSpacing }
            var x = bounds.minX
            var rowHeight: CGFloat = 0
            for itemIndex in row {
                let size = sizes[itemIndex]
                subviews[itemIndex].place(at: CGPoint(x: x, y: y), proposal: proposals[itemIndex])
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            y += rowHeight
        }
    }

    /// Groups item indices into rows for `sizes`, wrapping when adding another item would exceed `maxWidth`.
    /// When `balancesRows` is true and more than one row is needed, splits evenly across that row count
    /// (longer rows first), falling back to greedy wrapping if any balanced row would exceed `maxWidth`.
    public static func arrange(
        sizes: [CGSize],
        maxWidth: CGFloat,
        spacing: CGFloat,
        balancesRows: Bool = false
    ) -> [[Int]] {
        guard !sizes.isEmpty else { return [] }
        let rows = greedyRows(sizes: sizes, maxWidth: maxWidth, spacing: spacing)
        guard balancesRows, rows.count > 1 else { return rows }
        return balancedRows(sizes: sizes, rowCount: rows.count, maxWidth: maxWidth, spacing: spacing) ?? rows
    }

    private static func greedyRows(sizes: [CGSize], maxWidth: CGFloat, spacing: CGFloat) -> [[Int]] {
        var rows: [[Int]] = [[]]
        var currentWidth: CGFloat = 0

        for index in sizes.indices {
            let itemWidth = sizes[index].width
            let needed = rows[rows.count - 1].isEmpty ? itemWidth : currentWidth + spacing + itemWidth
            if needed > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([index])
                currentWidth = itemWidth
            } else {
                rows[rows.count - 1].append(index)
                currentWidth = needed
            }
        }
        return rows
    }

    private static func balancedRows(
        sizes: [CGSize],
        rowCount: Int,
        maxWidth: CGFloat,
        spacing: CGFloat
    ) -> [[Int]]? {
        var rows: [[Int]] = []
        rows.reserveCapacity(rowCount)
        var start = 0

        for line in 0..<rowCount {
            let remainingLines = rowCount - line
            let length = (sizes.count - start + remainingLines - 1) / remainingLines
            var row: [Int] = []
            row.reserveCapacity(length)
            var rowWidth: CGFloat = 0
            for index in start..<(start + length) {
                if !row.isEmpty { rowWidth += spacing }
                rowWidth += sizes[index].width
                row.append(index)
            }
            guard rowWidth <= maxWidth else { return nil }
            rows.append(row)
            start += length
        }
        return rows
    }

    private func fittedProposal(for subview: LayoutSubview, maxWidth: CGFloat) -> ProposedViewSize {
        let natural = subview.sizeThatFits(.unspecified)
        return maxWidth.isFinite && natural.width > maxWidth
            ? ProposedViewSize(width: maxWidth, height: nil)
            : .unspecified
    }

    private func fittedSize(of subview: LayoutSubview, maxWidth: CGFloat) -> CGSize {
        subview.sizeThatFits(fittedProposal(for: subview, maxWidth: maxWidth))
    }
}
