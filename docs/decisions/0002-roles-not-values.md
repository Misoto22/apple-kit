# 0002. Roles, not values

Date: 2026-11-27. Status: accepted.

## Context

The four brands share nothing visible: kioku is paper and ink with moss, Kura Martian Mono with orange, Jade Optima with
jade green, Revala New York with Geist Mono. Their motion rules contradict each other (kioku only springs, Jade never
springs, Revala a standard bezier).

## Decision

Fluent UI Apple's split: global values belong to each brand and are never shared; alias roles have shared *names*; the
control-level look belongs to each app. `Theme` holds only the roles a shared behaviour reads (`paper`, `ink`,
`secondaryInk`, `hairline`, `scrim`, `accent`, `skeleton`, and `MotionSet`'s `quick`, `standard`, `breath`). Each app maps its
own tokens into it once at its root with `.misotoTheme(_:)`.

## Consequences

A behaviour (a glass sheet turning to paper, a privacy cover, a breathing placeholder) looks like the app it runs in.
A role is added only when a behaviour needs it.
