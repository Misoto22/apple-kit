import Foundation

/// Seam for biometric/device-owner verification paired with ``CoverWindow``.
public protocol OwnerAuthenticating: Sendable {
    func authenticate(reason: String) async -> Bool
}

/// Relock grace-period state machine shared by apps that lock on backgrounding.
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

    /// Evaluates whether the app should lock upon returning to the foreground at `now`.
    @discardableResult
    public mutating func willEnterForeground(at now: Date = Date()) -> Bool {
        defer { backgroundedAt = nil }
        guard let backgroundedAt else { return isLocked }
        if now.timeIntervalSince(backgroundedAt) >= graceInterval {
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
}
