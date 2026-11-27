import MisotoMotion
import MisotoTheme
import SwiftUI

/// Determinate progress indicator switching between `.ring` and `.bar` via `Theme.Variants.ProgressStyle`.
public struct MisotoProgress: View {
    public var value: Double
    public var size: CGFloat
    public var lineWidth: CGFloat

    @Environment(\.misotoTheme) private var theme
    @ReduceMotion private var reduceMotion

    public init(value: Double, size: CGFloat = 28, lineWidth: CGFloat = 3.5) {
        self.value = min(max(value, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Group {
            switch theme.variants.progress {
            case .ring:
                ZStack {
                    Circle()
                        .stroke(theme.colors.hairline, lineWidth: lineWidth)
                    Circle()
                        .trim(from: 0, to: value)
                        .stroke(theme.colors.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: size, height: size)
            case .bar:
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(theme.colors.hairline)
                        Capsule(style: .continuous)
                            .fill(theme.colors.accent)
                            .frame(width: proxy.size.width * value)
                    }
                }
                .frame(height: max(4, lineWidth * 1.5))
            }
        }
        .animation(Motion.unless(reduceMotion, Motion.quick), value: value)
        .accessibilityValue("\(Int((value * 100).rounded()))%")
    }
}
