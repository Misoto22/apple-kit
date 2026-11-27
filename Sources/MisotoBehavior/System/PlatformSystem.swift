import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Platform-level system actions.
public enum PlatformSystem {
    #if os(iOS)
    /// Opens the app's own page in iOS Settings. Unavailable in app extensions.
    @available(iOSApplicationExtension, unavailable)
    @MainActor
    public static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    #elseif os(macOS)
    /// Opens macOS System Settings.
    @MainActor
    public static func openSettings() {
        guard let url = URL(string: "x-apple.systempreferences:") else { return }
        NSWorkspace.shared.open(url)
    }
    #endif
}
