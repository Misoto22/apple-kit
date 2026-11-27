import MisotoMotion
import MisotoTheme
import SwiftUI

/// Breathing skeleton placeholder shapes and common row presets.
public struct MisotoSkeleton: View {
    public enum ShapeKind: Sendable, Hashable {
        case line(width: CGFloat? = nil, height: CGFloat = 14)
        case circle(size: CGFloat)
        case card(height: CGFloat = 88)
    }

    private let kind: ShapeKind
    private let delay: Double
    @Environment(\.misotoTheme) private var theme

    public init(_ kind: ShapeKind = .line(), delay: Double = 0) {
        self.kind = kind
        self.delay = delay
    }

    public var body: some View {
        Group {
            switch kind {
            case .line(let width, let height):
                RoundedRectangle(cornerRadius: theme.radii.small, style: .continuous)
                    .fill(theme.colors.skeleton)
                    .frame(maxWidth: width ?? .infinity)
                    .frame(height: height)
            case .circle(let size):
                Circle()
                    .fill(theme.colors.skeleton)
                    .frame(width: size, height: size)
            case .card(let height):
                RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
                    .fill(theme.colors.skeleton)
                    .frame(height: height)
            }
        }
        .breathing(while: true, delay: delay)
        .accessibilityHidden(true)
    }
}

/// Multi-line skeleton row preset.
public struct MisotoSkeletonRow: View {
    private let showLeadingCircle: Bool
    @Environment(\.misotoTheme) private var theme

    public init(showLeadingCircle: Bool = true) {
        self.showLeadingCircle = showLeadingCircle
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            if showLeadingCircle {
                MisotoSkeleton(.circle(size: 36))
            }
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                MisotoSkeleton(.line(width: 160, height: 14), delay: 0.05)
                MisotoSkeleton(.line(height: 12), delay: 0.12)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MisotoStrings.loading)
    }
}
