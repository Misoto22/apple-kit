import Foundation
import MisotoFoundation
import Testing

private func response(_ headers: [String: String]) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 429, httpVersion: nil, headerFields: headers)!
}

struct RetryAfterTests {
    @Test func wholeSecondsKeepTheirInteger() {
        #expect(RetryAfter(header: " 7 ") == .seconds(7, whole: 7))
    }

    @Test func fractionalSecondsHaveNoWholeValue() {
        #expect(RetryAfter(header: "1.5") == .seconds(1.5, whole: nil))
    }

    @Test(arguments: ["nan", "NaN", "inf", "-inf", "infinity"])
    func nonFiniteIsNoHint(_ raw: String) {
        #expect(RetryAfter(header: raw) == nil)
    }

    @Test func negativeSecondsWaitNothing() {
        let value = RetryAfter(header: "-3")
        #expect(value == .seconds(-3, whole: nil))
        #expect(value?.delay() == 0)
    }

    @Test func anHTTPDateIsAWaitFromNow() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let value = try #require(RetryAfter(header: "Tue, 14 Nov 2023 22:13:40 GMT"))
        #expect(value.delay(now: now) == 20)
        #expect(value.delay(now: now.addingTimeInterval(60)) == 0)
    }

    @Test func garbageIsNoHint() {
        #expect(RetryAfter(header: "soon") == nil)
    }

    @Test func hintFallsBackToTheRateLimitReset() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(RetryAfter.hint(response(["X-RateLimit-Reset": "1700000030"]), now: now) == 30)
        #expect(RetryAfter.hint(response(["X-RateLimit-Reset": "12"]), now: now) == 12)
        #expect(RetryAfter.hint(response(["X-RateLimit-Reset": "nan"]), now: now) == nil)
        #expect(RetryAfter.hint(response([:]), now: now) == nil)
    }

    @Test func retryAfterWinsOverTheReset() {
        #expect(RetryAfter.hint(response(["Retry-After": "4", "X-RateLimit-Reset": "99"])) == 4)
    }
}
