import MisotoLayout
import MisotoMotion
import MisotoTheme
import SwiftUI

/// Accessible stepper with long-press repeat support and localized increment/decrement labels.
public struct MisotoStepper: View {
    @Binding public var value: Int
    public let range: ClosedRange<Int>
    public let step: Int
    private let label: LocalizedStringKey?

    @Environment(\.misotoTheme) private var theme
    @State private var repeatTask: Task<Void, Never>?

    public init(
        _ label: LocalizedStringKey? = nil,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = max(1, step)
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            if let label {
                Text(label)
                    .font(theme.typography.body.font)
                    .foregroundStyle(theme.colors.ink)
                Spacer(minLength: theme.spacing.sm)
            }
            HStack(spacing: 0) {
                stepButton(systemImage: "minus", accessibilityLabel: MisotoStrings.decrement, delta: -step, enabled: value > range.lowerBound)
                Text("\(value)")
                    .font(theme.typography.mono.font)
                    .foregroundStyle(theme.colors.ink)
                    .frame(minWidth: 36)
                    .numericRoll()
                stepButton(systemImage: "plus", accessibilityLabel: MisotoStrings.increment, delta: step, enabled: value < range.upperBound)
            }
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)
                    .strokeBorder(theme.colors.hairline, lineWidth: theme.elevation.strokeWidth)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: adjust(by: step)
            case .decrement: adjust(by: -step)
            @unknown default: break
            }
        }
        .onDisappear {
            repeatTask?.cancel()
            repeatTask = nil
        }
    }

    private func stepButton(systemImage: String, accessibilityLabel: String, delta: Int, enabled: Bool) -> some View {
        Button {
            adjust(by: delta)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(enabled ? theme.colors.ink : theme.colors.tertiaryInk)
                .frame(width: 36, height: 34)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(accessibilityLabel)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.35)
                .onEnded { _ in startRepeating(delta: delta) }
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 20, pressing: { pressing in
            if !pressing {
                repeatTask?.cancel()
                repeatTask = nil
            }
        }, perform: {})
        .hitTargetOutset()
    }

    private func adjust(by delta: Int) {
        let next = min(max(value + delta, range.lowerBound), range.upperBound)
        if next != value { value = next }
    }

    private func startRepeating(delta: Int) {
        repeatTask?.cancel()
        repeatTask = Task { @MainActor in
            while !Task.isCancelled {
                adjust(by: delta)
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }
}
