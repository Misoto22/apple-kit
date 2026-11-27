import Foundation
import Synchronization

#if os(iOS)
@preconcurrency import BackgroundTasks
#endif

/// The one call a background run makes when it ends. `BGTask` conforms; a test passes a recorder.
public protocol BackgroundTaskCompleting: AnyObject {
    func setTaskCompleted(success: Bool)
}

#if os(iOS)
extension BGTask: BackgroundTaskCompleting {}
#endif

/// A background task's one `setTaskCompleted`, however many ways the run ends.
///
/// A run ends twice when it expires: the system's expiration handler, which has to end the task at once (a task still
/// open when its time is up gets the process killed), and the run itself, once the cancellation it was handed has
/// unwound. Whichever comes first completes the task; the other does nothing.
///
/// `Sendable`, so the expiration handler can be a `@Sendable` closure: one written in a main-actor function is main-actor
/// isolated, and the system does not say which queue it calls that handler on. The task is only reached through the mutex.
public final class BackgroundTaskCompletion: BackgroundTaskCompleting, @unchecked Sendable {
    private let task: any BackgroundTaskCompleting
    private let completed = Mutex(false)

    public init(_ task: any BackgroundTaskCompleting) {
        self.task = task
    }

    /// Whether the task has been completed, by either end.
    public var isCompleted: Bool { completed.withLock { $0 } }

    public func setTaskCompleted(success: Bool) {
        let first = completed.withLock { done in
            defer { done = true }
            return !done
        }
        guard first else { return }
        task.setTaskCompleted(success: success)
    }

    /// The expiration handler: cancel the run, and end the task now rather than when the run has unwound.
    public func expire(cancelling run: Task<Void, Never>) {
        run.cancel()
        setTaskCompleted(success: false)
    }

    /// Ends the task once `submission` (the request for the next run) has gone out: the system may suspend the app the
    /// moment the task completes, and a request still in flight then never reaches the scheduler. A nil submission ends
    /// it at once.
    public func complete(success: Bool, after submission: Task<Void, Never>?) async {
        await submission?.value
        setTaskCompleted(success: success)
    }
}

#if os(iOS)
/// Registration that cannot trap.
///
/// `BGTaskScheduler.register(forTaskWithIdentifier:using: nil, ...)` calls the handler on the scheduler's own queue.
/// Written in an `App` or any main-actor type, the handler is main-actor isolated, and Swift 6's executor check traps
/// there: kioku-ios's daily background crash (TestFlight 1.15.2). Here the queue is always the main one and the handler is
/// declared `@MainActor`, so the check holds and the type system says where it runs.
@available(iOSApplicationExtension, unavailable)
public enum BackgroundTasks {
    /// Registers `handler` for `identifier` on the main queue. Call before the app finishes launching, once per
    /// identifier. Returns false when the identifier is not in the Info.plist's permitted list.
    @MainActor
    @discardableResult
    public static func register(
        _ identifier: String,
        scheduler: BGTaskScheduler = .shared,
        handler: @escaping @MainActor (BGTask) -> Void
    ) -> Bool {
        scheduler.register(forTaskWithIdentifier: identifier, using: .main) { task in
            MainActor.assumeIsolated { handler(task) }
        }
    }
}
#endif
