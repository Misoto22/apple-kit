import Foundation
import MisotoFoundation
import Synchronization
import Testing

struct RateLimitRetryTests {
    private func response(status: Int, retryAfter: String? = nil) -> HTTPURLResponse {
        var headers: [String: String] = [:]
        if let retryAfter { headers["Retry-After"] = retryAfter }
        return HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }

    @Test func doesNotRetryOnSuccess() async throws {
        let calls = Mutex(0)
        let (_, res) = try await RateLimitRetry.perform {
            calls.withLock { $0 += 1 }
            return (Data("ok".utf8), response(status: 200))
        }
        #expect(res.statusCode == 200)
        #expect(calls.withLock { $0 } == 1)
    }

    @Test func retriesOnceAfterHintedDelayOn429() async throws {
        let calls = Mutex(0)
        let slept = Mutex([TimeInterval]())
        let (data, res) = try await RateLimitRetry.perform(
            maxDelay: 10,
            sleep: { delay in slept.withLock { $0.append(delay) } }
        ) {
            let attempt = calls.withLock { count in
                count += 1
                return count
            }
            if attempt == 1 {
                return (Data(), response(status: 429, retryAfter: "2"))
            }
            return (Data("recovered".utf8), response(status: 200))
        }
        #expect(res.statusCode == 200)
        #expect(String(data: data, encoding: .utf8) == "recovered")
        #expect(calls.withLock { $0 } == 2)
        #expect(slept.withLock { $0 } == [2])
    }

    @Test func skipsRetryWhenDelayExceedsMax() async throws {
        let calls = Mutex(0)
        let slept = Mutex(false)
        let (_, res) = try await RateLimitRetry.perform(
            maxDelay: 5,
            sleep: { _ in slept.withLock { $0 = true } }
        ) {
            calls.withLock { $0 += 1 }
            return (Data(), response(status: 429, retryAfter: "60"))
        }
        #expect(res.statusCode == 429)
        #expect(calls.withLock { $0 } == 1)
        #expect(!slept.withLock { $0 })
    }

    @Test func supportsGenericPayloadWithFallbackAndCappedDelay() async throws {
        var calls = 0
        var slept: [TimeInterval] = []
        let urlResponse: URLResponse = response(status: 429)
        let okResponse: URLResponse = response(status: 200)

        let (text, secondResponse) = try await RateLimitRetry.perform(
            maxDelay: 65,
            fallbackDelay: 2,
            capDelay: true,
            sleep: { slept.append($0) }
        ) {
            calls += 1
            if calls == 1 {
                return ("limited", urlResponse)
            }
            return ("ok", okResponse)
        }
        #expect(text == "ok")
        #expect((secondResponse as? HTTPURLResponse)?.statusCode == 200)
        #expect(slept == [2])

        var cappedSleep: [TimeInterval] = []
        calls = 0
        _ = try await RateLimitRetry.perform(
            maxDelay: 65,
            fallbackDelay: 2,
            capDelay: true,
            sleep: { cappedSleep.append($0) }
        ) {
            calls += 1
            return (calls, response(status: 429, retryAfter: "600") as URLResponse)
        }
        #expect(cappedSleep == [65])
        #expect(calls == 2)
    }
}
