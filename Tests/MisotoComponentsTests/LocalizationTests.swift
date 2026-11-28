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
        #expect(Set(strings.keys) == ["loading", "toggle_off", "toggle_on", "undo"])

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

    @Test func bundleModuleStringsResolveNonEmptyAndLocalizeAllSixLanguages() throws {
        #expect(!MisotoStrings.loading.isEmpty)
        #expect(!MisotoStrings.toggleOn.isEmpty)
        #expect(!MisotoStrings.toggleOff.isEmpty)
        #expect(!MisotoStrings.undo.isEmpty)

        var loadingByLocale: [String: String] = [:]
        for lang in requiredLanguages {
            let lprojURL = try #require(
                MisotoStrings.resourceBundle.url(forResource: lang, withExtension: "lproj"),
                "Missing compiled .lproj bundle for \(lang)"
            )
            let langBundle = try #require(Bundle(url: lprojURL))
            let resolved = langBundle.localizedString(forKey: "loading", value: nil, table: nil)
            #expect(!resolved.isEmpty && resolved != "loading")
            loadingByLocale[lang] = resolved
        }
        #expect(Set(loadingByLocale.values).count == requiredLanguages.count)

        if let preferred = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first {
            for (prefix, expected) in [("ja", "読み込み中"), ("fr", "Chargement"), ("ko", "불러오는 중"), ("zh-Hans", "加载中"), ("zh-Hant", "載入中")] {
                if preferred.hasPrefix(prefix) {
                    #expect(MisotoStrings.loading == expected)
                }
            }
        }
    }
}
