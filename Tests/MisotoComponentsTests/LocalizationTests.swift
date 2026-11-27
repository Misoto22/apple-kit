import Foundation
import MisotoComponents
import Testing

struct LocalizationTests {
    private let requiredLanguages: Set<String> = ["en", "fr", "ja", "ko", "zh-Hans", "zh-Hant"]

    @Test func stringCatalogCoversAllSixLanguagesForEveryKey() throws {
        let catalogURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/MisotoComponents/Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: catalogURL)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let strings = try #require(json["strings"] as? [String: Any])
        #expect(strings.count >= 11)

        for (key, entryAny) in strings {
            let entry = try #require(entryAny as? [String: Any], "Missing entry for \(key)")
            let localizations = try #require(entry["localizations"] as? [String: Any], "Missing localizations for \(key)")
            for lang in requiredLanguages {
                let langEntry = try #require(localizations[lang] as? [String: Any], "Missing \(lang) for \(key)")
                let unit = try #require(langEntry["stringUnit"] as? [String: Any], "Missing stringUnit for \(key)/\(lang)")
                let value = try #require(unit["value"] as? String)
                #expect(!value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Empty \(lang) value for \(key)")
            }
        }
    }

    @Test func bundleModuleStringsResolveNonEmpty() {
        #expect(!MisotoStrings.undo.isEmpty)
        #expect(!MisotoStrings.retry.isEmpty)
        #expect(!MisotoStrings.cancel.isEmpty)
        #expect(!MisotoStrings.save.isEmpty)
        #expect(!MisotoStrings.close.isEmpty)
        #expect(!MisotoStrings.clear.isEmpty)
        #expect(!MisotoStrings.search.isEmpty)
        #expect(!MisotoStrings.loading.isEmpty)
        #expect(!MisotoStrings.increment.isEmpty)
        #expect(!MisotoStrings.decrement.isEmpty)
        let formatted = MisotoStrings.item(2, of: 5)
        #expect(formatted.contains("2") && formatted.contains("5"))
    }
}
