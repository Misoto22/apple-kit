# 0001. What belongs in AppleKit

Date: 2026-11-27. Updated: 2026-11-28. Status: accepted.

## Context

Four Apple apps (`kioku-ios`, `revala-ios`, `kura-ios`, `jade`), four GitHub organisations, one maintainer. Initially AppleKit restricted itself to foundation and unstyled behaviour. A subsequent full-codebase audit found 19 shared component categories, Liquid Glass sheet mechanics, motion orchestration, and layout primitives duplicated 2 to 4 times across the apps.

Unlike Material Components for iOS (which failed by replacing platform controls with custom renderers), these four apps share one maintainer and build strictly on top of SwiftUI/UIKit native controls.

## Decision

AppleKit is the shared design-system foundation for the Misoto apps under four strict guardrails:

1. **Two-app rule**: Structure enters AppleKit only when at least two apps share it. Single-app features (`kura`'s long-press confirm, `revala`'s map pins/mascot, `jade`'s pet and direct-sale Mac Washi controls, `kioku`'s charts/maps) stay in their app.
2. **Closed named variants (≤ 3)**: Components share structure, state, accessibility, Dynamic Type, tap targets, and localization; visual differences become closed value-type variants (at most 3 per component) in `Theme.Variants`, never arbitrary view closures passed from apps.
3. **Never wrap unmodified system containers**: `List`, `NavigationStack`, `TabView`, system alerts, and page-level settings skeletons stay in the apps.
4. **Gallery and snapshot verification**: Shared components are verified across all four brand themes, light/dark, largest Dynamic Type, Increase Contrast, and iPhone/iPad/macOS before adoption.

One repository, layered products enforced by `Package.swift` so lower layers cannot import higher ones:
`MisotoFoundation` → `MisotoTheme` / `MisotoMotion` / `MisotoLayout` → `MisotoBehavior` → `MisotoComponents`, plus `MisotoTesting`.
