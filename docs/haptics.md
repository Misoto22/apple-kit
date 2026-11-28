# Haptics Vocabulary

All four Misoto apps (`kioku-ios`, `revala-ios`, `kura-ios`, `jade`) follow the same haptic rules without a custom Swift wrapper—SwiftUI's native `.sensoryFeedback(_:trigger:)` and `UIKit` feedback generators already share identical system semantics.

## Canonical Triggers

| Intent | SwiftUI Feedback | Examples |
| --- | --- | --- |
| Choice, filter pill, segment, detent snap | `.selection` | Switching tabs/lenses, selecting a chip, picker change |
| Action completed / verified | `.success` | Save confirmed, unlock succeeded, toast undo applied |
| Recoverable limit or validation caution | `.warning` | Offline queue deferral, rate-limit pause |
| Rejected action or error | `.error` | Failed unlock, destructive validation error |
| Tactile button / drag threshold | `.impact(weight: .light)` / `.impact(weight: .medium)` | Long-press lock threshold, pull-to-refresh trigger |

## Rules

1. Fire haptics only on explicit user actions or meaningful completion boundaries—never inside continuous scroll offsets or repetitive timers.
2. Pair every destructive confirmation or unlock outcome with distinct visual/VoiceOver state so haptic-disabled devices never lose feedback.
3. Prefer SwiftUI `.sensoryFeedback(_:trigger:)` over manual `UIImpactFeedbackGenerator` allocations in views.
