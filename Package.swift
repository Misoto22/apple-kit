// swift-tools-version: 6.2
//
// AppleKit: what kioku-ios, revala-ios, kura-ios and jade share.
//
// Layers, lowest first. A target may depend only on targets above it in this list; the manifest is the rule, so a
// lower layer importing a higher one does not compile.
//
// - MisotoFoundation: Foundation, Security, ImageIO, BackgroundTasks. Extension-safe (iOS/macOS/watchOS).
// - MisotoTheme:      SwiftUI value-type design tokens and roles (`Theme`, `ColorPair`, `FontRole`, `ShadowToken`).
// - MisotoMotion:     Unified motion curves, durations, Reduce Motion entry points, and orchestration modifiers.
// - MisotoLayout:     Shared layout primitives (FlowLayout, EqualWidthRow, readableWidth, 44 pt hit target).
// - MisotoBehavior:   Liquid Glass & paper surface material, sheets, privacy cover, appearance window, scene readers, tab fade.
// - MisotoComponents: Shared SwiftUI components with closed named variants and 6-language localized strings.
// - MisotoTesting:    Test doubles and multi-brand Theme fixtures.
// - MisotoGallery:    Internal multi-brand component gallery for snapshot matrix verification (not shipped as a product).
//
// Swift 6 language mode everywhere: the isolation checks this package exists to get right are Swift 6's.

import PackageDescription

let package = Package(
    name: "AppleKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26)],
    products: [
        .library(name: "MisotoFoundation", targets: ["MisotoFoundation"]),
        .library(name: "MisotoTheme", targets: ["MisotoTheme"]),
        .library(name: "MisotoMotion", targets: ["MisotoMotion"]),
        .library(name: "MisotoLayout", targets: ["MisotoLayout"]),
        .library(name: "MisotoBehavior", targets: ["MisotoBehavior"]),
        .library(name: "MisotoComponents", targets: ["MisotoComponents"]),
        .library(name: "MisotoTesting", targets: ["MisotoTesting"]),
    ],
    targets: [
        .target(name: "MisotoFoundation"),
        .target(name: "MisotoTheme"),
        .target(name: "MisotoMotion"),
        .target(name: "MisotoLayout"),
        .target(
            name: "MisotoBehavior",
            dependencies: ["MisotoTheme", "MisotoMotion"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "MisotoComponents",
            dependencies: ["MisotoTheme", "MisotoMotion", "MisotoLayout", "MisotoBehavior"],
            resources: [.process("Resources")]
        ),
        .target(name: "MisotoTesting", dependencies: ["MisotoFoundation", "MisotoTheme"]),
        .target(
            name: "MisotoGallery",
            dependencies: ["MisotoTheme", "MisotoMotion", "MisotoLayout", "MisotoBehavior", "MisotoComponents", "MisotoTesting"]
        ),
        .testTarget(name: "MisotoFoundationTests", dependencies: ["MisotoFoundation", "MisotoTesting"]),
        .testTarget(name: "MisotoThemeTests", dependencies: ["MisotoTheme", "MisotoTesting"]),
        .testTarget(name: "MisotoMotionTests", dependencies: ["MisotoMotion"]),
        .testTarget(name: "MisotoLayoutTests", dependencies: ["MisotoLayout"]),
        .testTarget(name: "MisotoBehaviorTests", dependencies: ["MisotoBehavior", "MisotoTheme", "MisotoMotion"]),
        .testTarget(
            name: "MisotoComponentsTests",
            dependencies: ["MisotoComponents", "MisotoGallery", "MisotoTesting"],
            exclude: ["__Snapshots__"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
