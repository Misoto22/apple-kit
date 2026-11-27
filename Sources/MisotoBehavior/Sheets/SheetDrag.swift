import CoreGraphics

/// Pure drag-target projection and rubber-banding math shared by custom bottom sheets and panels.
public enum SheetPosition {
    /// Minimum downward velocity (pt/s) treated as an intentional flick to collapse/dismiss.
    public static let flickVelocity: CGFloat = 300
    /// Minimum displacement (pt) from rest that triggers collapsing without a fast flick.
    public static let collapseDistance: CGFloat = 32
    /// Velocity projection horizon (seconds) used when predicting release resting position.
    public static let projectionTime: CGFloat = 0.2
    /// Standard iOS-matching rubber-band damping coefficient beyond detent bounds.
    public static let rubberBandFactor: CGFloat = 0.55

    /// Applies rubber-band resistance for an overshoot `delta` beyond a `limit` span.
    public static func rubberBand(offset: CGFloat, limit: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0 }
        let absOffset = abs(offset)
        let damped = (1 - (1 / ((absOffset * rubberBandFactor / limit) + 1))) * limit
        return offset >= 0 ? damped : -damped
    }

    /// Selects the target detent index from `detents` (ordered lowest-to-highest or smallest-to-largest offset)
    /// given the current `offset`, `velocity`, and available `stops`.
    public static func targetStop(
        current: CGFloat,
        velocity: CGFloat,
        stops: [CGFloat]
    ) -> CGFloat? {
        guard !stops.isEmpty else { return nil }
        if velocity >= flickVelocity {
            return stops.max()
        }
        if velocity <= -flickVelocity {
            return stops.min()
        }
        let projected = current + velocity * projectionTime
        return stops.min(by: { abs($0 - projected) < abs($1 - projected) })
    }

    /// Whether a drag that moved `translation` at `velocity` should dismiss/collapse from rest.
    public static func shouldCollapse(translation: CGFloat, velocity: CGFloat) -> Bool {
        velocity >= flickVelocity || translation >= collapseDistance
    }
}
