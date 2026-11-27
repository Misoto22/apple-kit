import SwiftUI

/// Unified pull-to-refresh wrapper using the system gesture and `LoadingTiming` minimum display cadence.
private struct MisotoRefreshModifier: ViewModifier {
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.refreshable {
            let startedAt = Date()
            await action()
            let elapsed = Date().timeIntervalSince(startedAt)
            let remaining = LoadingTiming.minimumDisplay - elapsed
            if remaining > 0 {
                try? await Task.sleep(for: .seconds(remaining))
            }
        }
    }
}

extension View {
    /// Applies system pull-to-refresh with unified minimum indicator display (`600 ms`).
    public func misotoRefreshable(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(MisotoRefreshModifier(action: action))
    }
}
