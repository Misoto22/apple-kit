import Foundation

/// HTTP 429 single-retry policy built on top of ``RetryAfter``.
public enum RateLimitRetry {
    /// Performs `operation` once, and if the response status is 429 with a valid ``RetryAfter`` (or `X-RateLimit-Reset`)
    /// hint (or `fallbackDelay` when no hint is present) within `maxDelay` (or clamped when `capDelay` is `true`),
    /// waits for the delay and retries once.
    public static func perform<T>(
        maxDelay: TimeInterval = 30,
        fallbackDelay: TimeInterval? = nil,
        capDelay: Bool = false,
        now: () -> Date = Date.init,
        sleep: (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(for: .seconds(seconds.isFinite ? max(0, seconds) : 0))
        },
        operation: () async throws -> (T, HTTPURLResponse)
    ) async throws -> (T, HTTPURLResponse) {
        try await execute(maxDelay: maxDelay, fallbackDelay: fallbackDelay, capDelay: capDelay, now: now, sleep: sleep, operation: operation)
    }

    /// Variant accepting any `URLResponse` (such as `URLSession.data(for:)` or `URLSession.bytes(for:)`).
    @_disfavoredOverload
    public static func perform<T>(
        maxDelay: TimeInterval = 30,
        fallbackDelay: TimeInterval? = nil,
        capDelay: Bool = false,
        now: () -> Date = Date.init,
        sleep: (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(for: .seconds(seconds.isFinite ? max(0, seconds) : 0))
        },
        operation: () async throws -> (T, URLResponse)
    ) async throws -> (T, URLResponse) {
        try await execute(maxDelay: maxDelay, fallbackDelay: fallbackDelay, capDelay: capDelay, now: now, sleep: sleep, operation: operation)
    }

    private static func execute<T, Response: URLResponse>(
        maxDelay: TimeInterval,
        fallbackDelay: TimeInterval?,
        capDelay: Bool,
        now: () -> Date,
        sleep: (TimeInterval) async throws -> Void,
        operation: () async throws -> (T, Response)
    ) async throws -> (T, Response) {
        let (value, response) = try await operation()
        guard let http = response as? HTTPURLResponse, http.statusCode == 429 else {
            return (value, response)
        }
        guard let rawDelay = RetryAfter.hint(http, now: now()) ?? fallbackDelay else {
            return (value, response)
        }
        let clampedLimit = max(0, maxDelay)
        if !capDelay && rawDelay > clampedLimit {
            return (value, response)
        }
        let delay = capDelay ? min(max(0, rawDelay), clampedLimit) : max(0, rawDelay)
        if delay > 0 {
            try await sleep(delay)
        }
        return try await operation()
    }
}
