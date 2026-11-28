# 0004. Three-tier boundary, 26+ baseline, and cross-platform matrix

Date: 2026-11-28. Status: accepted.

## Context

Supporting legacy OS versions (`macOS 14`) forced `@available(iOS 26, macOS 26, *)` guards across Liquid Glass APIs and `OSAllocatedUnfairLock` fallbacks, while `RevalaWatch`, `KiokuWidgets`, `RevalaWidgets`, `RevalaClip`, and `Revala` Android required explicit compilation and compatibility boundaries.

## Decision

1. **Three-tier architecture**:
   - Unified: motion values/orchestration, Liquid Glass-to-paper transitions, toast/loading timing, press feedback, and pull-to-refresh.
   - Shared structure + closed named variants (≤ 3): the adopted atomic components in `MisotoComponents` (`MisotoSpinner`, `MisotoProgress`, `MisotoToggleStyle`), plus unified timing engines (`ToastCenter`/`ToastTiming`, `LoadingActivity`/`LoadingTiming`) and `MisotoStrings` (see Decision 0006 for the Phase 4 Option B scope).
   - Brand-owned: DTCG token values, illustrations, mascots, and signature motions.
2. **Apple 26+ baseline**: `Package.swift` targets `[.iOS(.v26), .macOS(.v26), .watchOS(.v26)]`. All `@available(..., 26, *)` guards are removed, and `Synchronization.Mutex` is used directly.
3. **Platform & Extension matrix**:
   - iOS 26 & iPadOS 26: full support (including iPad Regular sheet geometry).
   - macOS 26 (`JadeMac` App Store): `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, `MisotoComponents`, and non-iOS parts of `MisotoBehavior`.
   - macOS 14+ (`jade` direct-sale): does not link `AppleKit`; consumes static motion constants from the DTCG pipeline.
   - watchOS 26 (`RevalaWatch`): `MisotoFoundation`, `MisotoTheme`, `MisotoMotion`, `MisotoLayout` only.
   - App Extensions (`Widgets`, `App Clips`): `Foundation`/`Theme`/`Motion`/`Layout` remain Extension-safe; `UIApplication`/`UIWindow` APIs stay in `MisotoBehavior` marked unavailable in extensions.
   - tvOS / visionOS: explicitly excluded until a real product targets them.
4. **Android compatibility**: Specifications and DTCG tokens are shared cross-platform (`tokens/` emits Swift, pure-JVM Kotlin matching `RevalaTokens.kt`, and CSS). Android keeps native Material 3 / Compose UI without simulating Liquid Glass; an `AndroidKit` is deferred until a second Android app exists.
