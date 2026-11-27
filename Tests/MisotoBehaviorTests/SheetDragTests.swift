import CoreGraphics
import MisotoBehavior
import Testing

struct SheetDragTests {
    @Test func rubberBandResistsBeyondLimit() {
        #expect(SheetPosition.rubberBand(offset: 0, limit: 100) == 0)
        let damped = SheetPosition.rubberBand(offset: 100, limit: 100)
        #expect(damped > 0 && damped < 100)
        let negative = SheetPosition.rubberBand(offset: -100, limit: 100)
        #expect(negative < 0 && negative > -100)
    }

    @Test func targetStopHonorsFlickVelocityAndProjection() {
        let stops: [CGFloat] = [0, 300, 600]
        #expect(SheetPosition.targetStop(current: 100, velocity: 350, stops: stops) == 600)
        #expect(SheetPosition.targetStop(current: 500, velocity: -350, stops: stops) == 0)
        #expect(SheetPosition.targetStop(current: 260, velocity: 100, stops: stops) == 300)
    }

    @Test func shouldCollapseTriggersOnFlickOrDistance() {
        #expect(SheetPosition.shouldCollapse(translation: 10, velocity: 300))
        #expect(SheetPosition.shouldCollapse(translation: 32, velocity: 0))
        #expect(!SheetPosition.shouldCollapse(translation: 20, velocity: 100))
    }
}
