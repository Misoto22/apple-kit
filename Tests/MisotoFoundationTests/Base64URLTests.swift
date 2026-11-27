import Foundation
import MisotoFoundation
import Testing

struct Base64URLTests {
    @Test func encodesAndDecodesWithoutPadding() {
        let bytes = Data([0xFB, 0xFF, 0xBF, 0x01, 0x02])
        let encoded = Base64URL.encode(bytes)
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))
        #expect(!encoded.contains("="))
        #expect(Base64URL.decode(encoded) == bytes)
    }

    @Test func decodesPaddedAndUnpaddedStrings() {
        let expected = Data("hello".utf8)
        #expect(Base64URL.decode("aGVsbG8") == expected)
        #expect(Base64URL.decode("aGVsbG8=") == expected)
    }

    @Test func rejectsMalformedLength() {
        #expect(Base64URL.decode("a") == nil)
    }
}
