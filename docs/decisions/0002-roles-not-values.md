# 0002. Roles, not values (with unified motion)

Date: 2026-11-27. Updated: 2026-11-28. Status: accepted.

## Context

Originally, each brand owned its own motion curves alongside its colours and typography. That split forced `MotionSet` into `Theme` while still leaving 180+ duplicated curves and orchestration helpers across the four apps. The maintainer decided to unify motion values and orchestration on Revala's cubic-bezier system across all four apps.

## Decision

- **Motion is unified**: Curves, durations, staggers, press feedback, and Reduce Motion orchestration live in `MisotoMotion` (backed by shared DTCG motion/timing tokens), so `MotionSet` is removed from `Theme`.
- **Brand values stay out of AppleKit**: Global values (colours including glass inks, font families, radii, spacing, elevation) stay in each brand's own DTCG token file (`*-brand`, or `kioku-ios`).
- **Semantic roles are shared**: `Theme` defines the modular role contract (`Colors`, `Typography`, `Radii`, `Spacing`, `Elevation`, `Variants`) mapped once at each app's root via `.misotoTheme(_:)`, with local overrides allowed as an escape hatch.
