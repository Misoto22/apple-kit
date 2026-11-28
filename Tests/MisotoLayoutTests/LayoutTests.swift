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
        // Greedy gives [[0, 1, 2], [3]] (widths 101, 70 -> 2 rows at maxWidth 101).
        // Balanced across 2 rows tries [0, 1] (48 <= 101) and [2, 3] (45 + 8 + 70 = 123 > 101), so it falls back to greedy.
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
}
