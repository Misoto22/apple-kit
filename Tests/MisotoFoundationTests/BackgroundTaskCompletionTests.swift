import Foundation
import MisotoFoundation
import os
import Testing

final class RecordingTask: BackgroundTaskCompleting, Sendable {
    private let calls = OSAllocatedUnfairLock(initialState: [Bool]())
    var completions: [Bool] { calls.withLock { $0 } }
    func setTaskCompleted(success: Bool) { calls.withLock { $0.append(success) } }
}

struct BackgroundTaskCompletionTests {
    @Test func completesOnceHoweverManyEndsCall() async {
        let task = RecordingTask()
        let completion = BackgroundTaskCompletion(task)
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<50 { group.addTask { completion.setTaskCompleted(success: index.isMultiple(of: 2)) } }
        }
        #expect(task.completions.count == 1)
        #expect(completion.isCompleted)
    }

    @Test func expiryCancelsTheRunAndEndsAtOnce() async {
        let task = RecordingTask()
        let completion = BackgroundTaskCompletion(task)
        let run = Task<Void, Never> { try? await Task.sleep(for: .seconds(60)) }
        completion.expire(cancelling: run)
        #expect(run.isCancelled)
        #expect(task.completions == [false])
        await completion.complete(success: true, after: nil)
        #expect(task.completions == [false], "the run's own end after expiry does nothing")
    }

    @Test func completeWaitsForTheNextSubmission() async {
        let task = RecordingTask()
        let completion = BackgroundTaskCompletion(task)
        let submitted = OSAllocatedUnfairLock(initialState: false)
        let submission = Task<Void, Never> {
            try? await Task.sleep(for: .milliseconds(50))
            submitted.withLock { $0 = true }
        }
        await completion.complete(success: true, after: submission)
        #expect(submitted.withLock { $0 })
        #expect(task.completions == [true])
    }
}
