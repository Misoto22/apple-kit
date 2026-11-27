# AppleKit

What kioku-ios, revala-ios, kura-ios and jade share, as one Swift package with three layers. Each app keeps its own
brand: colours, type, curves and the look of every component stay in the app.

| Product | Holds | Users today |
|---|---|---|
| `MisotoFoundation` | `GenericPassword` over a `KeychainItems` seam; `BackgroundTaskCompletion` and `BackgroundTasks.register`/`run` (always `using: .main`); `RetryAfter` (no non-finite wait); `AppleLanguages` (the in-app language choice's storage) | kioku-ios, kura-ios, revala-ios, jade |
| `MisotoTheme` | `RGBA`, `ColorPair` (light, dark and Increase Contrast, resolved off the main thread), `Theme` (the roles a behaviour reads), `MotionSet`, `.misotoTheme(_:)` | every app, at its root |
| `MisotoBehavior` | `SurfaceMaterial` (Liquid Glass turning to the app's paper with a sheet's lift) and `.surfaceMaterialSheet`; `CoverWindow` (a privacy cover or lock above everything); `.breathing`; `ReducedMotion`, `@ReduceMotion`, `.fadesInsteadOfMoving` | revala-ios, kioku-ios, kura-ios, jade |

Platforms: iOS 26, macOS 14 (jade's Mac app). Swift 6 language mode. No dependencies.

## Tokens

`tokens/` is the one token pipeline: a brand's DTCG tokens in, Swift that speaks MisotoTheme (and CSS) out, through
Style Dictionary. See `tokens/README.md`.

## Using it

In the app's `project.yml` (XcodeGen), once:

```yaml
packages:
  AppleKit:
    url: https://github.com/Misoto22/apple-kit.git
    minorVersion: 0.1.0
targets:
  App:
    dependencies:
      - package: AppleKit
        product: MisotoFoundation
```

At the root view, map the app's own tokens to the roles once:

```swift
WindowGroup { @Sendable in window }   // window = RootView().misotoTheme(AppTheme.current)
```

To work on AppleKit and an app together, point the app at a local checkout instead of the URL
(`path: ../../apple-kit` under `packages:`), and put the URL back before the pull request.

## Rules

1. **Local first.** Something new is written in an app. It moves here when a second app needs the same thing, with no
   behaviour change in either (decision 0001).
2. **Behaviour, not looks.** No brand colour, font or component appearance lives here. A behaviour reads the app's
   `Theme` roles (decision 0002).
3. **A small public surface.** Prefer a struct with static members to a public enum an app switches over: adding a case
   is a breaking change in Swift.
4. **Swift 6 isolation is the point.** Every system callback this package registers states where it runs.
5. **Batched releases.** Merge the release pull request when a batch is worth shipping, not after every change. Each app
   pins the minor version once (decision 0003).

## Developing

```sh
swift test                                   # macOS host
xcodebuild test -scheme AppleKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17'   # iOS, where UIKit and BackgroundTasks exist
```

Commits follow Conventional Commits; release-please writes the version and the changelog.
