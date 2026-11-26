import Foundation
import MisotoFoundation
import Testing

struct AppleLanguagesTests {
    @Test func aChoiceIsReadBackFromItsOwnDomain() {
        let suite = "misoto.test.languages.\(UUID().uuidString)"
        let languages = AppleLanguages(suiteName: suite, domain: suite)
        #expect(languages.chosen == nil)
        languages.choose(["zh-Hans"])
        #expect(languages.chosen == ["zh-Hans"])
        #expect(languages.effective.first == "zh-Hans")
        languages.choose(nil)
        #expect(languages.chosen == nil)
        UserDefaults().removePersistentDomain(forName: suite)
    }

    @Test func noDomainIsNoChoice() {
        #expect(AppleLanguages(suiteName: nil, domain: nil).chosen == nil)
    }
}
