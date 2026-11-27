import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Reduce Motion, decided in one place: movement becomes a fade or nothing, never a choice each page makes.
public enum ReducedMotion {
    /// The system setting, for code outside a view (a transaction, UIKit/AppKit).
    /// Inside SwiftUI views, prefer ``ReduceMotion`` so `\.forcesReduceMotion` in galleries and tests also applies.
    @MainActor public static var isOn: Bool {
        #if canImport(UIKit) && !os(watchOS)
        UIAccessibility.isReduceMotionEnabled
        #elseif canImport(AppKit)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        false
        #endif
    }

    /// `animation`, or nil when Reduce Motion is on: the change lands at once.
    @MainActor public static func unlessReduced(_ animation: Animation?) -> Animation? {
        isOn ? nil : animation
    }

    /// `animation`, or nil when `reduceMotion` is set: for a view that read the environment.
    public static func unless(_ reduceMotion: Bool, _ animation: Animation?) -> Animation? {
        reduceMotion ? nil : animation
    }
}

extension EnvironmentValues {
    /// Forces Reduce Motion on below, whatever the system says: a debug gallery's switch, a test.
    @Entry public var forcesReduceMotion: Bool = false
}

/// Whether motion is reduced here: the system's setting, or `\.forcesReduceMotion`.
@propertyWrapper
public struct ReduceMotion: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var system
    @Environment(\.forcesReduceMotion) private var forced

    public init() {}

    public var wrappedValue: Bool { system || forced }
}
