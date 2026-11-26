# 0001. What belongs in AppleKit

Date: 2026-11-27. Status: accepted.

## Context

Four iOS apps, four GitHub organisations, one maintainer. An audit (2026-11-27) found the same infrastructure written two
to four times: Keychain wrappers in all four, background-task completion in two, the in-app language override in three,
Retry-After parsing in two, a privacy window above alerts in two, a loading breath in four. Each copy carried its own
bugs; kioku-ios crashed daily on one of them.

Large companies that share code across apps (Uber's Rider/Driver/Eats, Airbnb's module types, Spotify's Encore,
Microsoft's Fluent UI Apple, Google's Material Components for iOS) agree on two lessons: shared foundations pay off, and a
shared *visual* component library tends to fight the platform (Material Components for iOS went into maintenance in 2021
and was archived in 2025, advising the system's own SwiftUI and UIKit components).

## Decision

A piece moves here only when two apps use it and it can move without a behaviour change in either. It stays in the app
when only one app has it (jade's CloudKit zone engine, kura's sealed files, revala's map), or when the apps mean different
things by the same name (kioku's `LoadPhase` is a five-case enum, revala's a generic result with a timeout).

One repository, three products, layered so the manifest forbids a lower layer importing a higher one.

## Consequences

The package stays small and each type in it has at least two users that test it. An app wanting something new writes it
locally first.
