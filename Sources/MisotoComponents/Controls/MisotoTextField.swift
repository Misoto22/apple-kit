import MisotoTheme
import SwiftUI

/// Form text field with label, optional error message, and `.outlined` vs `.filled` variants.
public struct MisotoTextField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let prompt: LocalizedStringKey?
    private let errorMessage: String?

    @Environment(\.misotoTheme) private var theme
    @FocusState private var isFocused: Bool

    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        prompt: LocalizedStringKey? = nil,
        errorMessage: String? = nil
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.errorMessage = errorMessage
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)
        let borderColor: Color = if errorMessage != nil {
            theme.colors.error
        } else if isFocused {
            theme.colors.accent
        } else {
            theme.colors.hairline
        }

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.callout.font)
                .foregroundStyle(theme.colors.secondaryInk)

            TextField("", text: $text, prompt: prompt.map { Text($0) })
                .font(theme.typography.body.font)
                .foregroundStyle(theme.colors.ink)
                .focused($isFocused)
                .padding(.horizontal, theme.spacing.md - 4)
                .padding(.vertical, theme.spacing.sm + 2)
                .background {
                    switch theme.variants.field {
                    case .outlined:
                        shape.fill(theme.colors.paper)
                    case .filled:
                        shape.fill(theme.colors.surface)
                    }
                }
                .overlay(
                    shape.strokeBorder(borderColor, lineWidth: isFocused ? 1.5 : theme.elevation.strokeWidth)
                )

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(theme.typography.caption.font)
                    .foregroundStyle(theme.colors.error)
            }
        }
    }
}
