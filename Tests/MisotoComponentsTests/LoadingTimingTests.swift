import Foundation
import MisotoComponents
import Synchronization
import Testing

@MainActor
struct LoadingTimingTests {
    @Test func transitionsThroughDelaySlowAndTimeout() async {
        let activity = LoadingActivity()
        #expect(activity.phase == .idle)

        let durations = Mutex([TimeInterval]())
        activity.begin(
            at: { Date(timeIntervalSince1970: 100) },
            sleep: { seconds in
                durations.withLock { $0.append(seconds) }
            }
        )

        for _ in 0..<10 { await Task.yield() }

        let recorded = durations.withLock { $0 }
        #expect(recorded.count == 3)
        #expect(abs(recorded[0] - LoadingTiming.placeholderDelay) < 1e-6)
        #expect(abs(recorded[1] - (LoadingTiming.slowThreshold - LoadingTiming.placeholderDelay)) < 1e-6)
        #expect(abs(recorded[2] - (LoadingTiming.timeout - LoadingTiming.slowThreshold)) < 1e-6)
        #expect(activity.phase == .timedOut)

        await activity.finish(at: { Date(timeIntervalSince1970: 100.5) }, sleep: { _ in })
        #expect(activity.phase == .idle)
    }

    @Test func finishRespectsMinimumDisplayDurationAfterPlaceholderAppears() async {
        let activity = LoadingActivity()
        let extraSleep = Mutex([TimeInterval]())

        activity.begin(
            at: { Date(timeIntervalSince1970: 200) },
            sleep: { seconds in
                if seconds > LoadingTiming.placeholderDelay {
                    try await Task.sleep(for: .seconds(60))
                }
            }
        )

        for _ in 0..<5 { await Task.yield() }
        #expect(activity.phase == .showingPlaceholder)

        await activity.finish(
            at: { Date(timeIntervalSince1970: 200.1) },
            sleep: { seconds in extraSleep.withLock { $0.append(seconds) } }
        )

        let waited = extraSleep.withLock { $0 }
        #expect(waited.count == 1)
        #expect(abs(waited[0] - (LoadingTiming.minimumDisplay - 0.1)) < 1e-6)
        #expect(activity.phase == .idle)
    }

    @Test func staleFinishNeverClobbersANewerBegin() async {
        let activity = LoadingActivity()

        activity.begin(
            at: { Date(timeIntervalSince1970: 300) },
            sleep: { seconds in
                if seconds > LoadingTiming.placeholderDelay {
                    try await Task.sleep(for: .seconds(60))
                }
            }
        )
        for _ in 0..<5 { await Task.yield() }
        #expect(activity.phase == .showingPlaceholder)

        let finishTask = Task {
            await activity.finish(
                at: { Date(timeIntervalSince1970: 300.1) },
                sleep: { _ in try await Task.sleep(for: .milliseconds(30)) }
            )
        }
        await Task.yield()

        // A new load starts while the previous finish() is still waiting out minimumDisplay.
        activity.begin(
            at: { Date(timeIntervalSince1970: 300.15) },
            sleep: { _ in try await Task.sleep(for: .seconds(60)) }
        )
        #expect(activity.phase == .pendingBeforePlaceholder)

        await finishTask.value
        #expect(activity.phase == .pendingBeforePlaceholder, "Old finish() must not overwrite the newer begin() back to .idle")

        await activity.finish(at: { Date(timeIntervalSince1970: 301) }, sleep: { _ in })
        #expect(activity.phase == .idle)
    }
}
