import MisotoBehavior
import MisotoTheme
import SwiftUI

/// Surface card container declaring `containerShape` so inner views can use concentric corners,
/// and switching between `.outlined`, `.filled`, and `.glass` via `Theme.Variants.CardStyle`.
public struct MisotoCard<Content: View>: View {
    private let padding: CGFloat?
    private let content: Content

    @Environment(\.misotoTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(padding: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
        content
            .padding(padding ?? theme.spacing.md)
            .background {
                switch theme.variants.card {
                case .outlined:
                    shape.fill(theme.colors.paper)
                        .overlay(shape.strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
                case .filled:
                    shape.fill(theme.colors.surface)
                case .glass:
                    Color.clear.glassSurface(in: shape)
                }
            }
            .containerShape(shape)
            .modifier(CardShadowModifier(shadow: theme.elevation.card?.resolve(for: colorScheme)))
    }
}

private struct CardShadowModifier: ViewModifier {
    let shadow: ShadowToken?

    @ViewBuilder func body(content: Content) -> some View {
        if let shadow {
            content.shadow(color: shadow.swiftUIColor, radius: shadow.blur, x: shadow.x, y: shadow.y)
        } else {
            content
        }
    }
}
