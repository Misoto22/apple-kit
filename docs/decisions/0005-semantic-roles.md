# 0005. Semantic role schema

Date: 2026-11-28. Status: accepted.

## Context

`Theme` previously held 7 colour roles and `MotionSet`. Sharing 19 component categories across four brands (and mapping semantic roles consistently to Kotlin on Android) requires a complete, modular role schema that can grow without breaking call sites whenever a new token role is added.

## Decision

`Theme` is structured into six value-type modules with sensible defaults on `Theme.system`:

1. `Colors` (plus `Glass` sub-struct): `paper`, `surface`, `ink`, `secondaryInk`, `tertiaryInk`, `hairline`, `scrim`, `accent`, `onAccent`, `skeleton`, `success`, `warning`, `error`, and `glass` (`secondaryInk`, `tertiaryInk`, `wash`, `band`).
2. `Typography`: `title`, `headline`, `body`, `callout`, `caption`, `mono` (via `FontRole`, supporting system fonts and Dynamic-Type-scaled custom fonts).
3. `Radii`: `small`, `medium`, `large`, `control`, `card` (all rendered with `.rect(cornerRadius:style: .continuous)` or concentric shapes).
4. `Spacing`: `xs`, `sm`, `md`, `lg`, `xl`.
5. `Elevation`: `card`, `floating` (`ShadowPair?`), and `strokeWidth`.
6. `Variants`: closed value-type enums (≤ 3 cases each) selecting component appearances per app root, overridable locally via `\.misotoTheme.variants`.

All semantic role names map 1:1 between Swift (`Theme`) and generated Kotlin/CSS outputs from the DTCG token pipeline.
