import MisotoMotion
import MisotoTheme
import SwiftUI

/// Shared loading spinner whose structure, cadence, Reduce Motion still frame, and VoiceOver label stay uniform,
/// while appearance switches among the three closed variants in `Theme.Variants.SpinnerStyle`.
public struct MisotoSpinner: View {
    public var size: CGFloat
    public var lineWidth: CGFloat

    @Environment(\.misotoTheme) private var theme
    @ReduceMotion private var reduceMotion
    @State private var spinning = false

    public init(size: CGFloat = 20, lineWidth: CGFloat = 2.5) {
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Group {
            switch theme.variants.spinner {
            case .arc:
                arcView
            case .enso:
                ensoView
            case .markPulse:
                markPulseView
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(MisotoStrings.loading)
        .onAppear {
            guard !reduceMotion else { return }
            spinning = true
        }
        .onChange(of: reduceMotion) { _, reduced in
            spinning = !reduced
        }
    }

    private var arcView: some View {
        Circle()
            .trim(from: 0, to: 0.72)
            .stroke(theme.colors.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(spinning && !reduceMotion ? 360 : 0))
            .animation(
                reduceMotion ? nil : .linear(duration: 0.85).repeatForever(autoreverses: false),
                value: spinning
            )
            .breathing(while: reduceMotion, low: 0.55, still: 0.75)
    }

    private var ensoView: some View {
        Circle()
            .trim(from: 0.08, to: 0.92)
            .stroke(
                theme.colors.accent,
                style: StrokeStyle(lineWidth: lineWidth * 1.15, lineCap: .round)
            )
            .rotationEffect(.degrees(spinning && !reduceMotion ? 360 : -45))
            .animation(
                reduceMotion ? nil : .linear(duration: 1.1).repeatForever(autoreverses: false),
                value: spinning
            )
            .breathing(while: reduceMotion, low: 0.6, still: 0.85)
    }

    private var markPulseView: some View {
        Circle()
            .fill(theme.colors.accent)
            .scaleEffect(reduceMotion ? 0.85 : (spinning ? 1.0 : 0.7))
            .breathing(while: true, low: 0.45, still: 0.8)
    }
}
