// swift-tools-version: 6.2
//
// AppleKit: what kioku-ios, revala-ios, kura-ios and jade share, and nothing else (docs/decisions/0001).
//
// Layers, lowest first. A target may depend only on targets above it in this list; the manifest is the rule, so a
// lower layer importing a higher one does not compile.
//
// - MisotoFoundation: Foundation, Security, BackgroundTasks, os. No SwiftUI, no UIKit, no brand.
// - MisotoTheme:      SwiftUI value types for an app's roles (ColorPair, Theme, MotionSet) and the environment entry
//                     an app sets once at its root. No component, no brand value.
// - MisotoBehavior:   SwiftUI and UIKit behaviour without a look of its own (surface material, Reduce Motion, the
//                     privacy cover, load phases, sheets). Reads the app's Theme; draws nothing an app would restyle.
//
// Swift 6 language mode everywhere: the isolation checks this package exists to get right are Swift 6's.

import PackageDescription

let package = Package(
    name: "AppleKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v14)],
    products: [
        .library(name: "MisotoFoundation", targets: ["MisotoFoundation"]),
        .library(name: "MisotoTheme", targets: ["MisotoTheme"]),
        .library(name: "MisotoBehavior", targets: ["MisotoBehavior"]),
    ],
    targets: [
        .target(name: "MisotoFoundation"),
        .target(name: "MisotoTheme"),
        .target(name: "MisotoBehavior", dependencies: ["MisotoTheme"]),
        .testTarget(name: "MisotoFoundationTests", dependencies: ["MisotoFoundation"]),
        .testTarget(name: "MisotoThemeTests", dependencies: ["MisotoTheme"]),
        .testTarget(name: "MisotoBehaviorTests", dependencies: ["MisotoBehavior", "MisotoTheme"]),
    ],
    swiftLanguageModes: [.v6]
)
