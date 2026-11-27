import MisotoLayout
import MisotoTheme
import SwiftUI

/// Search input with magnifying-glass icon, localized placeholder, and accessible clear button.
public struct MisotoSearchField: View {
    @Binding private var text: String
    private let prompt: String?

    @Environment(\.misotoTheme) private var theme

    public init(text: Binding<String>, prompt: String? = nil) {
        self._text = text
        self.prompt = prompt
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.colors.secondaryInk)
                .accessibilityHidden(true)

            TextField(prompt ?? MisotoStrings.search, text: $text)
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.ink)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.colors.secondaryInk)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(MisotoStrings.clear)
                .hitTargetOutset()
            }
        }
        .padding(.horizontal, theme.spacing.md - 4)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface, in: shape)
        .overlay(shape.strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth))
    }
}
