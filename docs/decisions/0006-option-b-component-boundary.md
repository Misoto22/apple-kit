# 0006. Option B Component Boundary (Phase 4 Checkpoint)

Date: 2026-11-28. Status: accepted.

## Context

By `AppleKit v0.2.2`, all four Misoto apps (`kura-ios`, `jade`, `kioku-ios`, `revala-ios`) adopted unified foundation primitives, `MisotoMotion`, `MisotoLayout`, Liquid Glass & sheet behaviors (`MisotoBehavior`), and core feedback/control primitives (`MisotoSpinner`, `MisotoProgress`, `MisotoToggleStyle`, `ToastTiming`, `LoadingTiming`).

Fourteen high-level visual shell components (`MisotoButtonStyles`, `MisotoCard`, `MisotoChip`, `MisotoSearchField`, `MisotoSegmentedControl`, `MisotoStepper`, `MisotoTextField`, `MisotoBanner`, `MisotoEmptyState`, `MisotoErrorState`, `MisotoRefresh`, `MisotoSkeleton`, `MisotoSettingRow`, `MisotoSheetHeader`, `MisotoToastCapsule`) and two speculative infrastructure stubs (`ZoomablePhotoView`, `SemanticVersion`) remained at zero external callers across all four apps because each app's brand presentation, custom gesture model, or zero-dependency package boundary intentionally differs.

## Decision

Close Phase 4–6 using **Option B**:

1. **Keep brand-specific visual shells in the apps**: Do not force single-app structural differences or extra boolean flags into `MisotoComponents`. Each app retains its own visual shells built over shared `MisotoTheme`, `MisotoMotion`, `MisotoLayout`, and `MisotoBehavior` primitives.
2. **Prune 0-caller components and speculative stubs**: Remove the 14 uncalled visual shell files, `MisotoToastCapsule`, `ZoomablePhotoView`, and `SemanticVersion` from `AppleKit`, keeping only actively shared code (`MisotoSpinner`, `MisotoProgress`, `MisotoToggleStyle`, `ToastTiming`, `ToastCenter`, `LoadingTiming`, `LoadingActivity`, `MisotoStrings` / `Localizable.xcstrings`), plus narrow `Theme.Variants` to `{ SpinnerStyle, ProgressStyle, ToggleVariant }`.
3. **Complete genuinely shared behavior**: Upgrade `RelockPolicy` with fail-closed monotonic (`ContinuousClock`) and interval evaluators for `kioku-ios` and `kura-ios`.
4. **Harden verification & SSOT**: Maintain PNG snapshot regression tests across all four brand theme fixtures, appearances, Dynamic Type, accessibility settings, and platforms (macOS + iOS), alongside 1:1 DTCG token SSOT drift tests.
