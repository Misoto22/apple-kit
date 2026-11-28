import Foundation

/// Seam for biometric/device-owner verification paired with ``CoverWindow``.
public protocol OwnerAuthenticating: Sendable {
    func authenticate(reason: String) async -> Bool
}

/// Relock grace-period state machine and monotonic fail-closed evaluators shared by apps that lock on backgrounding.
public struct RelockPolicy: Sendable, Equatable {
    public var graceInterval: TimeInterval
    public var graceDuration: Duration
    public private(set) var backgroundedAt: Date?
    public private(set) var backgroundedInstant: ContinuousClock.Instant?
    public private(set) var isLocked: Bool

    public init(graceInterval: TimeInterval = 60, isLocked: Bool = false) {
        let clamped = max(0, graceInterval)
        self.graceInterval = clamped
        self.graceDuration = .seconds(clamped)
        self.isLocked = isLocked
    }

    public init(graceDuration: Duration, isLocked: Bool = false) {
        let clamped = max(.zero, graceDuration)
        self.graceDuration = clamped
        let comps = clamped.components
        self.graceInterval = Double(comps.seconds) + Double(comps.attoseconds) / 1e18
        self.isLocked = isLocked
    }

    public mutating func didEnterBackground(at now: Date = Date()) {
        if backgroundedAt == nil {
            backgroundedAt = now
        }
    }

    /// Monotonic-clock background entry timestamping.
    public mutating func didEnterBackground(at instant: ContinuousClock.Instant) {
        if backgroundedInstant == nil {
            backgroundedInstant = instant
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

    /// Monotonic-clock foreground evaluation (failing closed on negative duration or expiry).
    @discardableResult
    public mutating func willEnterForeground(at instant: ContinuousClock.Instant) -> Bool {
        defer { backgroundedInstant = nil }
        guard let backgroundedInstant else { return isLocked }
        if Self.shouldRelock(backgroundedAt: backgroundedInstant, now: instant, grace: graceDuration) {
            isLocked = true
        }
        return isLocked
    }

    public mutating func lock() {
        isLocked = true
        backgroundedAt = nil
        backgroundedInstant = nil
    }

    public mutating func unlock() {
        isLocked = false
        backgroundedAt = nil
        backgroundedInstant = nil
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
