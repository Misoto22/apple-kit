import Foundation
import SwiftUI

/// Localized UI and accessibility strings bundled inside `MisotoComponents`.
public enum MisotoStrings {
    public static var cancel: String { String(localized: "cancel", defaultValue: "Cancel", bundle: .module) }
    public static var clear: String { String(localized: "clear", defaultValue: "Clear", bundle: .module) }
    public static var close: String { String(localized: "close", defaultValue: "Close", bundle: .module) }
    public static var decrement: String { String(localized: "decrement", defaultValue: "Decrease", bundle: .module) }
    public static var increment: String { String(localized: "increment", defaultValue: "Increase", bundle: .module) }
    public static var loading: String { String(localized: "loading", defaultValue: "Loading", bundle: .module) }
    public static var retry: String { String(localized: "retry", defaultValue: "Retry", bundle: .module) }
    public static var save: String { String(localized: "save", defaultValue: "Save", bundle: .module) }
    public static var search: String { String(localized: "search", defaultValue: "Search", bundle: .module) }
    public static var undo: String { String(localized: "undo", defaultValue: "Undo", bundle: .module) }

    public static func item(_ index: Int, of total: Int) -> String {
        String(
            localized: "item_of_total",
            defaultValue: "Item \(Int64(index)) of \(Int64(total))",
            bundle: .module
        )
    }
}
