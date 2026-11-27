import Foundation
import Observation

/// Unified loading timing thresholds matching `tokens/shared/misoto-timing.tokens.json`.
public enum LoadingTiming {
    public static let placeholderDelay: TimeInterval = 0.40
    public static let minimumDisplay: TimeInterval = 0.60
    public static let slowThreshold: TimeInterval = 8.0
    public static let timeout: TimeInterval = 20.0
}

/// Phase of an asynchronous load respecting delay, minimum display time, slow notice, and timeout.
public enum LoadingActivityPhase: Sendable, Equatable {
    case idle
    case pendingBeforePlaceholder
    case showingPlaceholder
    case slowNotice
    case timedOut
}

/// State machine coordinating placeholder appearance (`400 ms`), minimum display (`600 ms`), slow warning (`8 s`),
/// and timeout (`20 s`).
@MainActor
@Observable
public final class LoadingActivity {
    public private(set) var phase: LoadingActivityPhase = .idle
    private var startedAt: Date?
    private var placeholderShownAt: Date?
    private var timerTask: Task<Void, Never>?

    public init() {}

    public func begin(
        at now: @escaping @Sendable () -> Date = Date.init,
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) }
    ) {
        timerTask?.cancel()
        startedAt = now()
        placeholderShownAt = nil
        phase = .pendingBeforePlaceholder

        timerTask = Task { [weak self] in
            do {
                try await sleep(LoadingTiming.placeholderDelay)
                guard !Task.isCancelled, let self else { return }
                self.placeholderShownAt = now()
                self.phase = .showingPlaceholder

                try await sleep(max(0, LoadingTiming.slowThreshold - LoadingTiming.placeholderDelay))
                guard !Task.isCancelled else { return }
                self.phase = .slowNotice

                try await sleep(max(0, LoadingTiming.timeout - LoadingTiming.slowThreshold))
                guard !Task.isCancelled else { return }
                self.phase = .timedOut
            } catch {}
        }
    }

    public func finish(
        at now: @Sendable () -> Date = Date.init,
        sleep: @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) }
    ) async {
        timerTask?.cancel()
        timerTask = nil
        if let shownAt = placeholderShownAt {
            let elapsed = now().timeIntervalSince(shownAt)
            let remaining = LoadingTiming.minimumDisplay - elapsed
            if remaining > 0 {
                try? await sleep(remaining)
            }
        }
        startedAt = nil
        placeholderShownAt = nil
        phase = .idle
    }
}
