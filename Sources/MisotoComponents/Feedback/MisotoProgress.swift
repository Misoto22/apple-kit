import Foundation
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Determinate progress indicator switching between `.ring` and `.bar` via `Theme.Variants.ProgressStyle`
/// (or an explicit `variant` parameter), with locale-aware percentage VoiceOver value formatting.
public struct MisotoProgress: View {
    public var value: Double
    public var size: CGFloat
    public var lineWidth: CGFloat
    public var variant: Theme.Variants.ProgressStyle?
    public var tint: Color?
    public var track: Color?

    @Environment(\.misotoTheme) private var theme
    @ReduceMotion private var reduceMotion

    public init(
        value: Double,
        size: CGFloat = 28,
        lineWidth: CGFloat = 3.5,
        variant: Theme.Variants.ProgressStyle? = nil,
        tint: Color? = nil,
        track: Color? = nil
    ) {
        self.value = min(max(value, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.variant = variant
        self.tint = tint
        self.track = track
    }

    private var resolvedVariant: Theme.Variants.ProgressStyle { variant ?? theme.variants.progress }
    private var resolvedTint: Color { tint ?? theme.colors.accent }
    private var resolvedTrack: Color { track ?? theme.colors.hairline }

    public var body: some View {
        Group {
            switch resolvedVariant {
            case .ring:
                ZStack {
                    Circle()
                        .stroke(resolvedTrack, lineWidth: lineWidth)
                    Circle()
                        .trim(from: 0, to: value)
                        .stroke(resolvedTint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: size, height: size)
            case .bar:
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(resolvedTrack)
                        Capsule(style: .continuous)
                            .fill(resolvedTint)
                            .frame(width: proxy.size.width * value)
                    }
                }
                .frame(height: max(4, lineWidth * 1.5))
            }
        }
        .animation(Motion.unless(reduceMotion, Motion.quick), value: value)
        .accessibilityValue(value.formatted(.percent.precision(.fractionLength(0))))
    }
}
