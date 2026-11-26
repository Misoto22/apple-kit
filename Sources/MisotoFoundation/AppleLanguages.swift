import Foundation

/// The languages an app asks the system for, in its own defaults domain: the in-app language choice, read and written the
/// way Settings › the app › Language does.
///
/// Storage only. Each app keeps its own resolver (which languages it offers, how it falls back, whether the choice takes
/// effect at once or at the next launch).
///
/// Holds the suite's name, not a `UserDefaults`: the SDK marks that class non-Sendable, and every instance over one suite
/// reads and writes the same values.
public struct AppleLanguages: Sendable, Hashable {
    public static let key = "AppleLanguages"

    /// The suite read and written, or nil for `UserDefaults.standard`.
    public var suiteName: String?
    /// The domain the choice is written to (the bundle identifier for `.standard`), read on its own so the device's
    /// global list never counts as a choice the owner made. Nil reads as no choice.
    public var domain: String?

    public init(suiteName: String? = nil, domain: String? = Bundle.main.bundleIdentifier) {
        self.suiteName = suiteName
        self.domain = domain
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    /// The app's own choice, or nil when it has made none.
    public var chosen: [String]? {
        guard let domain else { return nil }
        return defaults.persistentDomain(forName: domain)?[Self.key] as? [String]
    }

    /// The list the system reads for this app: its own choice, else the device's.
    public var effective: [String] {
        defaults.stringArray(forKey: Self.key) ?? Locale.preferredLanguages
    }

    /// Writes the choice, or removes it (back to the device's languages) for nil.
    public func choose(_ languages: [String]?) {
        if let languages {
            defaults.set(languages, forKey: Self.key)
        } else {
            defaults.removeObject(forKey: Self.key)
        }
    }

    /// The global domain's list, or nil where the sandbox does not let the app read it.
    public static var device: [String]? {
        UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)?[key] as? [String]
    }
}
