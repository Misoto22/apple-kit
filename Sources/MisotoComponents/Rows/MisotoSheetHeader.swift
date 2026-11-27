import MisotoTheme
import SwiftUI

/// Unified sheet header with close/cancel, optional primary confirm/save action, busy state, and keyboard shortcuts.
public struct MisotoSheetHeader: View {
    private let title: LocalizedStringKey
    private let isSaving: Bool
    private let canConfirm: Bool
    private let onCancel: () -> Void
    private let onSave: (() -> Void)?

    @Environment(\.misotoTheme) private var theme

    public init(
        _ title: LocalizedStringKey,
        isSaving: Bool = false,
        canConfirm: Bool = true,
        onCancel: @escaping () -> Void,
        onSave: (() -> Void)? = nil
    ) {
        self.title = title
        self.isSaving = isSaving
        self.canConfirm = canConfirm
        self.onCancel = onCancel
        self.onSave = onSave
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            Button(onSave == nil ? MisotoStrings.close : MisotoStrings.cancel, action: onCancel)
                .buttonStyle(.misotoText)
                .keyboardShortcut(.cancelAction)
                .disabled(isSaving)

            Spacer()

            Text(title)
                .font(theme.typography.headline.font)
                .foregroundStyle(theme.colors.ink)
                .lineLimit(1)

            Spacer()

            if let onSave {
                if isSaving {
                    MisotoSpinner(size: 18, lineWidth: 2)
                } else {
                    Button(MisotoStrings.save, action: onSave)
                        .buttonStyle(.misotoText)
                        .keyboardShortcut(.defaultAction)
                        .disabled(!canConfirm)
                }
            } else {
                // Balance spacing visually when there is no trailing action.
                Color.clear.frame(width: 44, height: 1)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm + 2)
    }
}
