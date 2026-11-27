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
}
