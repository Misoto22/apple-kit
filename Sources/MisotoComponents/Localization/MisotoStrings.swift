import Foundation

/// Localized UI and accessibility strings bundled inside `MisotoComponents`.
public enum MisotoStrings {
    public static var resourceBundle: Bundle { .module }

    public static var loading: String {
        String(localized: "loading", defaultValue: "Loading", bundle: .module)
    }

    public static var toggleOn: String {
        String(localized: "toggle_on", defaultValue: "On", bundle: .module)
    }

    public static var toggleOff: String {
        String(localized: "toggle_off", defaultValue: "Off", bundle: .module)
    }

    public static var undo: String {
        String(localized: "undo", defaultValue: "Undo", bundle: .module)
    }
}
