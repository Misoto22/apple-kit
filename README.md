# AppleKit

What `kioku-ios`, `revala-ios`, `kura-ios`, and `jade` share, as one layered Swift 6 package.

## Single Source of Truth (SSOT)

AppleKit owns **the semantic contract** (variable names, motion vocabulary, glass-to-paper mechanics, adopted atomic components, and 6-language UI strings). Each brand owns **only its values** in DTCG tokens validated against `tokens/schema/theme-schema.json`:

```swift
// At app root, once:
RootView()
    .misotoTheme(BrandTheme.current)

// Anywhere in views (no manual @Environment boilerplate required):
Text("Title")
    .misotoFont(\.headline)
    .foregroundStyle(.misotoInk)
    .background(.misotoPaper)
```

## Users today

| App / Package | Repo | Linked products |
| --- | --- | --- |
| `kioku-ios` | `Misoto22/kioku-ios` | `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, `MisotoBehavior`, `MisotoComponents`, `MisotoTesting` |
| `revala-ios` | `revala-app/revala-ios` | `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, `MisotoBehavior`, `MisotoComponents` |
| `kura-ios` | `kura-casa/kura-ios` | `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, `MisotoBehavior`, `MisotoComponents`, `MisotoTesting` |
| `jade` | `jade-the-cat/jade` (`JadeKit`) | `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, `MisotoBehavior`, `MisotoComponents`, `MisotoTesting` |

## Directory Structure

```text
Sources/
├── MisotoFoundation/      # Keychain, BackgroundTasks, RetryAfter, RateLimitRetry, Base64URL, AppleLanguages, ImageDownsampler
├── MisotoTheme/           # ColorPair, FontRole, ShadowToken, modular Theme, ShapeStyle (.misotoInk / .misotoPaper / .misotoFont)
├── MisotoMotion/          # Unified curves (CubicBezier, StandardEasing), Motion tokens & orchestration, @ReduceMotion
├── MisotoLayout/          # FlowLayout, EqualWidthRow, CardGrid, .readableWidth(), .hitTargetOutset()
├── MisotoBehavior/
│   ├── Glass/             # SurfaceMaterial, .surfaceMaterialSheet, GlassInkStyle, GlassFill, .glassSurface
│   ├── Sheets/            # SheetPosition, fittedSheet, guardsUnsavedChanges, bottomActionBar, pageTopEdge, sheetRootClose
│   └── System/            # CoverWindow, WindowSceneReader, AppearanceWindow, RelockPolicy, PlatformSystem
├── MisotoComponents/
│   ├── Feedback/          # MisotoSpinner, MisotoProgress, MisotoToast (ToastTiming/ToastCenter), LoadingTiming/LoadingActivity
│   ├── Controls/          # MisotoToggleStyle (.misoto)
│   ├── Localization/      # MisotoStrings (Bundle.module)
│   └── Resources/         # Localizable.xcstrings (en, fr, ja, ko, zh-Hans, zh-Hant)
├── MisotoGallery/         # Multi-brand gallery view for visual review & snapshot matrix verification
└── MisotoTesting/         # RecordingKeychain, BrandThemeFixtures

tokens/
├── schema/                # theme-schema.json (SSOT semantic key & $type contract)
├── shared/                # misoto-motion.tokens.json, misoto-timing.tokens.json
├── examples/              # complete-brand.tokens.json
├── build.mjs              # CLI (--swift, --theme, --css, --kotlin, --check)
├── formats.mjs            # Swift, Theme extension, CSS (dark + high contrast), pure-JVM Kotlin
└── test/                  # Schema validation, formatter, and SSOT drift tests
```

## Platforms & Extensions

Minimum platforms: **iOS 26 / iPadOS 26 / macOS 26 / watchOS 26**.

- `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`: iOS, iPadOS, macOS, watchOS, and Extension-safe (`Widgets`, `App Clips`).
- `MisotoBehavior`: iOS, iPadOS, macOS (`UIWindow`/`UIApplication` APIs marked `#if os(iOS)` and `@available(iOSApplicationExtension, unavailable)`).
- `MisotoComponents`: iOS, iPadOS, macOS.

## Token Pipeline (`tokens/`)

```sh
cd tokens && npm ci && npm test
node build.mjs examples/complete-brand.tokens.json \
  --swift Generated/BrandTokens.swift --enum KiokuTokens --theme kioku \
  --css generated/tokens.css \
  --kotlin generated/BrandTokens.kt --kotlin-package app.misoto.tokens
```

## Developing

```sh
swift test
xcodebuild test -scheme AppleKit-Package -destination 'platform=iOS Simulator,name=iPhone 17' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
