import Foundation

/// Seam for biometric/device-owner verification paired with ``CoverWindow``.
public protocol OwnerAuthenticating: Sendable {
    func authenticate(reason: String) async -> Bool
}

/// Relock grace-period state machine and monotonic fail-closed evaluators shared by apps that lock on backgrounding.
public struct RelockPolicy: Sendable, Equatable {
    public var graceInterval: TimeInterval
    public private(set) var backgroundedAt: Date?
    public private(set) var isLocked: Bool

    public init(graceInterval: TimeInterval = 60, isLocked: Bool = false) {
        self.graceInterval = max(0, graceInterval)
        self.isLocked = isLocked
    }

    public mutating func didEnterBackground(at now: Date = Date()) {
        if backgroundedAt == nil {
            backgroundedAt = now
        }
    }

    /// Evaluates whether the app should lock upon returning to the foreground at `now` (failing closed on clock rollback).
    @discardableResult
    public mutating func willEnterForeground(at now: Date = Date()) -> Bool {
        defer { backgroundedAt = nil }
        guard let backgroundedAt else { return isLocked }
        if Self.shouldRelock(afterAway: now.timeIntervalSince(backgroundedAt), grace: graceInterval) {
            isLocked = true
        }
        return isLocked
    }

    public mutating func lock() {
        isLocked = true
        backgroundedAt = nil
    }

    public mutating func unlock() {
        isLocked = false
        backgroundedAt = nil
    }

    /// Fail-closed check for a wall-clock elapsed interval: locks at `elapsed >= grace` or on negative elapsed time.
    public static func shouldRelock(afterAway elapsed: TimeInterval, grace: TimeInterval) -> Bool {
        elapsed < 0 || elapsed >= max(0, grace)
    }

    /// Fail-closed check for a monotonic elapsed duration: locks at `elapsed >= grace` or on negative elapsed time.
    public static func shouldRelock(afterAway elapsed: Duration, grace: Duration) -> Bool {
        elapsed < .zero || elapsed >= max(.zero, grace)
    }

    /// Monotonic-clock relock check from a nullable background timestamp (`false` if never backgrounded).
    public static func shouldRelock(
        backgroundedAt: ContinuousClock.Instant?,
        now: ContinuousClock.Instant,
        grace: Duration
    ) -> Bool {
        guard let backgroundedAt else { return false }
        return shouldRelock(afterAway: backgroundedAt.duration(to: now), grace: grace)
    }
}
