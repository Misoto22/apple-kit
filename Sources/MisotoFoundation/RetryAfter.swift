import Foundation

/// A server's "come back later": `Retry-After` as delta seconds or an HTTP date (RFC 9110 §10.2.3).
///
/// Parsing only. Each app keeps its own retry rule on top: kioku-ios waits on any hint and caps it, revala-ios waits only
/// on a short whole number of seconds. What both need is a parse that cannot hand a non-finite wait to `Task.sleep`:
/// `TimeInterval("nan")` parses, NaN passes every clamp (`max(nan, 0)` is NaN), and `Int64(_:)` in the sleep traps.
public enum RetryAfter: Sendable, Equatable {
    /// Delta seconds. `whole` is the value when the header was a plain non-negative integer, as RFC 9110 writes it.
    case seconds(TimeInterval, whole: Int?)
    /// An HTTP date.
    case date(Date)

    /// The `Retry-After` of `response`, or nil when it has none or it is neither form. Never non-finite.
    public init?(_ response: HTTPURLResponse) {
        guard let raw = response.value(forHTTPHeaderField: "Retry-After") else { return nil }
        self.init(header: raw)
    }

    public init?(header raw: String) {
        let value = raw.trimmingCharacters(in: .whitespaces)
        if let seconds = TimeInterval(value) {
            guard seconds.isFinite else { return nil }
            self = .seconds(seconds, whole: Int(value).flatMap { $0 >= 0 ? $0 : nil })
        } else if let date = Self.httpDate(value) {
            self = .date(date)
        } else {
            return nil
        }
    }

    /// The wait from `now`, never negative.
    public func delay(now: Date = Date()) -> TimeInterval {
        switch self {
        case .seconds(let seconds, _): max(seconds, 0)
        case .date(let date): max(date.timeIntervalSince(now), 0)
        }
    }

    /// The server's own wait in seconds, never negative and not capped: `Retry-After`, else `X-RateLimit-Reset` as an
    /// epoch timestamp or a delta. Nil when the answer carries neither, so a caller can tell "no hint" from "now".
    public static func hint(_ response: HTTPURLResponse, now: Date = Date()) -> TimeInterval? {
        if let retryAfter = RetryAfter(response) {
            return retryAfter.delay(now: now)
        }
        if let raw = response.value(forHTTPHeaderField: "X-RateLimit-Reset"),
           let reset = TimeInterval(raw.trimmingCharacters(in: .whitespaces)), reset.isFinite {
            // An epoch timestamp dwarfs any plausible delta: split on that.
            return max(reset > 1_000_000_000 ? reset - now.timeIntervalSince1970 : reset, 0)
        }
        return nil
    }

    private static func httpDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: value)
    }
}
