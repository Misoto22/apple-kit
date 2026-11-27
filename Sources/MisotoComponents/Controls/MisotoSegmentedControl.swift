import MisotoBehavior
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Segmented control with `.glass` / `.solid` track variants and localized VoiceOver index readout ("Item X of Y").
public struct MisotoSegmentedControl<Option: Hashable>: View {
    public let options: [Option]
    @Binding public var selection: Option
    private let title: (Option) -> String

    @Environment(\.misotoTheme) private var theme
    @ReduceMotion private var reduceMotion
    @Namespace private var indicatorNamespace

    public init(
        options: [Option],
        selection: Binding<Option>,
        title: @escaping (Option) -> String
    ) {
        self.options = options
        self._selection = selection
        self.title = title
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                let isSelected = option == selection
                Button {
                    withAnimation(Motion.unless(reduceMotion, Motion.snappy)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(theme.typography.callout.font.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? theme.colors.ink : theme.colors.secondaryInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.xs + 2)
                        .padding(.horizontal, theme.spacing.sm)
                        .background {
                            if isSelected {
                                Capsule(style: .continuous)
                                    .fill(theme.variants.segmentedTrack == .glass ? theme.colors.glass.band : theme.colors.paper)
                                    .matchedGeometryEffect(id: "segmentIndicator", in: indicatorNamespace)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(title(option))
                .accessibilityValue(MisotoStrings.item(index + 1, of: options.count))
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .padding(3)
        .modifier(TrackSurfaceModifier())
    }
}

private struct TrackSurfaceModifier: ViewModifier {
    @Environment(\.misotoTheme) private var theme

    @ViewBuilder func body(content: Content) -> some View {
        if theme.variants.segmentedTrack == .glass {
            content.glassSurface(in: Capsule())
        } else {
            content
                .background(theme.colors.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
        }
    }
}
