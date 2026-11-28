import MisotoLayout
import SwiftUI
import Testing

struct LayoutTests {
    @Test func flowLayoutInitializesWithSpacingsAndRowBalancing() {
        let uniform = FlowLayout(spacing: 10)
        #expect(uniform.spacing == 10)
        #expect(uniform.lineSpacing == 10)
        #expect(!uniform.balancesRows)

        let custom = FlowLayout(spacing: 10, lineSpacing: 14, balancesRows: true)
        #expect(custom.spacing == 10)
        #expect(custom.lineSpacing == 14)
        #expect(custom.balancesRows)
    }

    @Test func flowLayoutArrangeWrapsWhenWidthIsExceeded() {
        let sizes = [
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
        ]
        // Three 50-pt items + two 8-pt gaps = 166 pt fit on line 1; fourth item wraps.
        let rows = FlowLayout.arrange(sizes: sizes, maxWidth: 166, spacing: 8, balancesRows: false)
        #expect(rows == [[0, 1, 2], [3]])
    }

    @Test func flowLayoutArrangeBalancesRowsEvenlyWhenEnabled() {
        let sizes = [
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
            CGSize(width: 50, height: 20),
        ]
        let balanced = FlowLayout.arrange(sizes: sizes, maxWidth: 166, spacing: 8, balancesRows: true)
        #expect(balanced == [[0, 1], [2, 3]])
    }

    @Test func flowLayoutArrangeFallsBackToGreedyIfBalancedRowWouldOverflow() {
        let mixed = [
            CGSize(width: 20, height: 20),
            CGSize(width: 20, height: 20),
            CGSize(width: 45, height: 20),
            CGSize(width: 70, height: 20),
        ]
        let rows = FlowLayout.arrange(sizes: mixed, maxWidth: 101, spacing: 8, balancesRows: true)
        #expect(rows == [[0, 1, 2], [3]])
    }

    @Test func equalWidthRowInitializesWithCustomSpacing() {
        let row = EqualWidthRow(spacing: 12)
        #expect(row.spacing == 12)
    }

    @Test func hitAreaExpandsSmallBoundsCenteredAndKeepsLargeBoundsUnchanged() {
        let small = HitArea().path(in: CGRect(x: 10, y: 10, width: 16, height: 20)).boundingRect
        #expect(small == CGRect(x: -4, y: -2, width: 44, height: 44))

        let large = HitArea().path(in: CGRect(x: 0, y: 0, width: 60, height: 48)).boundingRect
        #expect(large == CGRect(x: 0, y: 0, width: 60, height: 48))
    }

    @MainActor
    @Test func hitTargetOutsetPreservesVisualLayoutSize() {
        let plain = ImageRenderer(content: Color.red.frame(width: 12, height: 12))
        plain.scale = 1.0
        let outset = ImageRenderer(content: Color.red.frame(width: 12, height: 12).hitTargetOutset())
        outset.scale = 1.0

        #expect(plain.cgImage?.width == 12)
        #expect(plain.cgImage?.height == 12)
        #expect(outset.cgImage?.width == 12)
        #expect(outset.cgImage?.height == 12)
    }
}
