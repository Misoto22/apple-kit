import MisotoFoundation
import Testing

struct SemanticVersionTests {
    @Test func parsesTwoAndThreeComponentVersions() {
        #expect(SemanticVersion("1.2")?.description == "1.2.0")
        #expect(SemanticVersion("v2.10.4")?.description == "2.10.4")
        #expect(SemanticVersion("3.0.1-beta.1+42")?.description == "3.0.1")
        #expect(SemanticVersion("1") == nil)
        #expect(SemanticVersion("not-a-version") == nil)
        #expect(SemanticVersion("-1.0.0") == nil)
    }

    @Test func comparesNumericallyNotLexicographically() throws {
        let v1_9 = try #require(SemanticVersion("1.9.0"))
        let v1_10 = try #require(SemanticVersion("1.10.0"))
        let v2_0 = try #require(SemanticVersion("2.0"))
        #expect(v1_9 < v1_10)
        #expect(v1_10 < v2_0)
    }
}
