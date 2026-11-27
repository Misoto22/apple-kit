import MisotoMotion
import SwiftUI
import Testing

struct MotionTests {
    @Test func standardCurveMatchesEndpointsAndIsMonotonic() {
        #expect(StandardEasing.value(0) == 0)
        #expect(StandardEasing.value(1) == 1)
        let quarter = StandardEasing.value(0.25)
        let mid = StandardEasing.value(0.5)
        let threeQuarter = StandardEasing.value(0.75)
        #expect(quarter > 0 && quarter < mid)
        #expect(mid < threeQuarter && threeQuarter < 1)
    }

    @Test func unlessDropsTheAnimationWhenReduced() {
        #expect(ReducedMotion.unless(true, Motion.quick) == nil)
        #expect(ReducedMotion.unless(false, Motion.quick) == Motion.quick)
    }

    @Test func pressIsInstantWhenPressedAndQuickOnRelease() {
        #expect(Motion.press(isPressed: true, reduceMotion: false) == nil)
        #expect(Motion.press(isPressed: false, reduceMotion: false) == Motion.quick)
        #expect(Motion.press(isPressed: false, reduceMotion: true) == nil)
    }

    @Test func foldDelaysArrivalAndSuppressesWhenReduced() {
        #expect(Motion.fold(arriving: false, reduceMotion: false) == Motion.quick)
        #expect(Motion.fold(arriving: true, reduceMotion: false) == Motion.standard.delay(Motion.fast))
        #expect(Motion.fold(arriving: true, reduceMotion: true) == nil)
    }
}
