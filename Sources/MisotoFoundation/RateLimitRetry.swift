import Foundation

/// HTTP 429 single-retry policy built on top of ``RetryAfter``.
public enum RateLimitRetry {
    /// Performs `operation` once, and if the response status is 429 with a valid ``RetryAfter`` (or `X-RateLimit-Reset`)
    /// hint within `maxDelay`, waits for the hinted delay and retries once.
    public static func perform(
        maxDelay: TimeInterval = 30,
        now: @Sendable () -> Date = Date.init,
        sleep: @Sendable (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(for: .seconds(seconds))
        },
        operation: @Sendable () async throws -> (Data, HTTPURLResponse)
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await operation()
        guard response.statusCode == 429 else {
            return (data, response)
        }
        guard let delay = RetryAfter.hint(response, now: now()), delay <= maxDelay else {
            return (data, response)
        }
        if delay > 0 {
            try await sleep(delay)
        }
        return try await operation()
    }
}
