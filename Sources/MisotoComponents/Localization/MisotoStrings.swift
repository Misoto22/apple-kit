import Foundation
import SwiftUI

/// Localized UI and accessibility strings bundled inside `MisotoComponents`.
public enum MisotoStrings {
    public static var cancel: String { String(localized: "cancel", bundle: .module) }
    public static var clear: String { String(localized: "clear", bundle: .module) }
    public static var close: String { String(localized: "close", bundle: .module) }
    public static var decrement: String { String(localized: "decrement", bundle: .module) }
    public static var increment: String { String(localized: "increment", bundle: .module) }
    public static var loading: String { String(localized: "loading", bundle: .module) }
    public static var retry: String { String(localized: "retry", bundle: .module) }
    public static var save: String { String(localized: "save", bundle: .module) }
    public static var search: String { String(localized: "search", bundle: .module) }
    public static var undo: String { String(localized: "undo", bundle: .module) }

    public static func item(_ index: Int, of total: Int) -> String {
        let format = String(localized: "item_of_total", bundle: .module)
        return String.localizedStringWithFormat(format, Int64(index), Int64(total))
    }
}
