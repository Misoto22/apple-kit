import Foundation
import Observation

/// Unified loading timing thresholds matching `tokens/shared/misoto-timing.tokens.json`.
public enum LoadingTiming {
    public static let placeholderDelay: TimeInterval = GeneratedTimingTokens.Loading.placeholderDelay
    public static let minimumDisplay: TimeInterval = GeneratedTimingTokens.Loading.minimumDisplay
    public static let slowThreshold: TimeInterval = GeneratedTimingTokens.Loading.slowThreshold
    public static let timeout: TimeInterval = GeneratedTimingTokens.Loading.timeout
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
/// and timeout (`20 s`), guarded by a generation token so overlapping `begin()` / `finish()` calls never clobber a
/// newer load.
@MainActor
@Observable
public final class LoadingActivity {
    public private(set) var phase: LoadingActivityPhase = .idle
    private var placeholderShownAt: Date?
    private var timerTask: Task<Void, Never>?
    private var generation: UInt64 = 0

    public init() {}

    public func begin(
        at now: @escaping @Sendable () -> Date = Date.init,
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) }
    ) {
        generation &+= 1
        let token = generation
        timerTask?.cancel()
        placeholderShownAt = nil
        phase = .pendingBeforePlaceholder

        timerTask = Task { [weak self] in
            do {
                try await sleep(LoadingTiming.placeholderDelay)
                guard !Task.isCancelled, let self, self.generation == token else { return }
                self.placeholderShownAt = now()
                self.phase = .showingPlaceholder

                try await sleep(max(0, LoadingTiming.slowThreshold - LoadingTiming.placeholderDelay))
                guard !Task.isCancelled, self.generation == token else { return }
                self.phase = .slowNotice

                try await sleep(max(0, LoadingTiming.timeout - LoadingTiming.slowThreshold))
                guard !Task.isCancelled, self.generation == token else { return }
                self.phase = .timedOut
            } catch {}
        }
    }

    public func finish(
        at now: @Sendable () -> Date = Date.init,
        sleep: @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) }
    ) async {
        let token = generation
        timerTask?.cancel()
        timerTask = nil
        if let shownAt = placeholderShownAt {
            let elapsed = now().timeIntervalSince(shownAt)
            let remaining = LoadingTiming.minimumDisplay - elapsed
            if remaining > 0 {
                try? await sleep(remaining)
            }
        }
        guard generation == token else { return }
        placeholderShownAt = nil
        phase = .idle
    }
}
