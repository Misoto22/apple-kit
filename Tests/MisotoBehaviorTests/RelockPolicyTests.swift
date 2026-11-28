import Foundation
import MisotoBehavior
import Testing

struct RelockPolicyTests {
    @Test func staysUnlockedWithinGracePeriodAndLocksAfterExpiry() {
        let t0 = Date(timeIntervalSince1970: 1_000)
        var policy = RelockPolicy(graceInterval: 60)
        policy.didEnterBackground(at: t0)
        let lockedEarly = policy.willEnterForeground(at: t0.addingTimeInterval(59))
        #expect(!lockedEarly)
        #expect(!policy.isLocked)

        policy.didEnterBackground(at: t0)
        let lockedAfterGrace = policy.willEnterForeground(at: t0.addingTimeInterval(60))
        #expect(lockedAfterGrace)
        #expect(policy.isLocked)

        policy.unlock()
        #expect(!policy.isLocked)
    }

    @Test func wallClockRollbackFailsClosed() {
        let t0 = Date(timeIntervalSince1970: 1_000)
        var policy = RelockPolicy(graceInterval: 300)
        policy.didEnterBackground(at: t0)
        let locked = policy.willEnterForeground(at: t0.addingTimeInterval(-1))
        #expect(locked)
        #expect(policy.isLocked)
    }

    @Test func monotonicInstanceStateTracksGraceExpiryRollbackAndUnlock() {
        let clock = ContinuousClock()
        let t0 = clock.now
        var policy = RelockPolicy(graceDuration: .seconds(60))

        policy.didEnterBackground(at: t0)
        #expect(policy.backgroundedInstant == t0)
        let earlyLocked = policy.willEnterForeground(at: t0.advanced(by: .seconds(59)))
        #expect(!earlyLocked)
        #expect(!policy.isLocked)
        #expect(policy.backgroundedInstant == nil)

        policy.didEnterBackground(at: t0)
        let expiredLocked = policy.willEnterForeground(at: t0.advanced(by: .seconds(60)))
        #expect(expiredLocked)
        #expect(policy.isLocked)

        policy.unlock()
        #expect(!policy.isLocked)

        policy.didEnterBackground(at: t0)
        let rollbackLocked = policy.willEnterForeground(at: t0.advanced(by: .seconds(-2)))
        #expect(rollbackLocked)
        #expect(policy.isLocked)
    }

    @Test func timeIntervalEvaluatorHandlesBoundaryAndRollback() {
        #expect(RelockPolicy.shouldRelock(afterAway: 0, grace: 0))
        #expect(!RelockPolicy.shouldRelock(afterAway: 59.9, grace: 60))
        #expect(RelockPolicy.shouldRelock(afterAway: 60, grace: 60))
        #expect(RelockPolicy.shouldRelock(afterAway: 61, grace: 60))
        #expect(RelockPolicy.shouldRelock(afterAway: -0.5, grace: 60))
    }

    @Test func monotonicClockEvaluatorHandlesBoundaryNilAndRollback() {
        let clock = ContinuousClock()
        let t0 = clock.now
        let grace = Duration.seconds(300)

        #expect(!RelockPolicy.shouldRelock(backgroundedAt: nil, now: t0, grace: grace))
        #expect(!RelockPolicy.shouldRelock(backgroundedAt: t0, now: t0.advanced(by: .seconds(299)), grace: grace))
        #expect(RelockPolicy.shouldRelock(backgroundedAt: t0, now: t0.advanced(by: .seconds(300)), grace: grace))
        #expect(RelockPolicy.shouldRelock(backgroundedAt: t0, now: t0.advanced(by: .seconds(301)), grace: grace))
        #expect(RelockPolicy.shouldRelock(backgroundedAt: t0, now: t0.advanced(by: .seconds(-1)), grace: grace))
        #expect(RelockPolicy.shouldRelock(afterAway: .zero, grace: .zero))
        #expect(RelockPolicy.shouldRelock(afterAway: .seconds(-5), grace: .seconds(60)))
    }
}
