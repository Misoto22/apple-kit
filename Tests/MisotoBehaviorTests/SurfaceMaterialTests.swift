import MisotoBehavior
import SwiftUI
import Testing

struct SurfaceMaterialTests {
    @Test func paperIsNoneAtRestAndWholeNearTheTop() {
        #expect(SurfaceMaterial.paper(lift: 0) == 0)
        #expect(SurfaceMaterial.paper(lift: -1) == 0)
        #expect(SurfaceMaterial.paper(lift: 0.95) == 1)
        #expect(SurfaceMaterial.paper(lift: 1) == 1)
    }

    @Test func paperComesInSlowlyThenFaster() {
        let half = SurfaceMaterial.paper(lift: 0.475)
        #expect(abs(half - 0.125) < 1e-9, "a cube: an eighth of the paper halfway up")
        #expect(SurfaceMaterial.paper(lift: 0.3) < SurfaceMaterial.paper(lift: 0.6))
    }

    @Test func glassUntilHalfThePaperCovers() {
        #expect(SurfaceMaterial.isGlass(lift: 0.7))
        #expect(!SurfaceMaterial.isGlass(lift: 0.8))
    }

    @Test func systemLiftFollowsTheTopEdge() {
        #expect(SurfaceMaterial.systemLift(top: 400, restTop: 400, fullTop: 60) == 0)
        #expect(SurfaceMaterial.systemLift(top: 60, restTop: 400, fullTop: 60) == 1)
        #expect(SurfaceMaterial.systemLift(top: 230, restTop: 400, fullTop: 60) == 0.5)
        #expect(SurfaceMaterial.systemLift(top: 500, restTop: 400, fullTop: 60) == 0)
        #expect(SurfaceMaterial.systemLift(top: 50, restTop: 60, fullTop: 60) == 1, "a degenerate range reads the top alone")
    }

    @Test func rampIsFlatOutsideItsEnds() {
        #expect(SurfaceMaterial.ramp(-1, from: 0, to: 1) == 0)
        #expect(SurfaceMaterial.ramp(0.5, from: 0, to: 1) == 0.5)
        #expect(SurfaceMaterial.ramp(2, from: 0, to: 1) == 1)
    }

    @Test func aSheetIsPaperAtLargeAloneOverASheetOrCenteredOnPad() {
        #expect(SurfaceMaterial.isPaper(selected: .large, detents: [.medium, .large]))
        #expect(!SurfaceMaterial.isPaper(selected: .medium, detents: [.medium, .large]))
        #expect(SurfaceMaterial.isPaper(selected: .large, detents: [.large]))
        #expect(SurfaceMaterial.isPaper(selected: .medium, detents: [.medium], overSheet: true))
        #expect(SurfaceMaterial.isPaper(selected: .medium, detents: [.medium], isCentered: true))
    }
}
