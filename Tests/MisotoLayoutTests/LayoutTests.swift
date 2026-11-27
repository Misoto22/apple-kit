import MisotoLayout
import SwiftUI
import Testing

struct LayoutTests {
    @Test func flowLayoutInitializesWithCustomSpacings() {
        let flow = FlowLayout(spacing: 10, lineSpacing: 14)
        #expect(flow.spacing == 10)
        #expect(flow.lineSpacing == 14)
    }

    @Test func equalWidthRowInitializesWithCustomSpacing() {
        let row = EqualWidthRow(spacing: 12)
        #expect(row.spacing == 12)
    }
}
