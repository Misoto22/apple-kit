import Foundation
import Observation

/// Timing constants matching `tokens/shared/misoto-timing.tokens.json`.
public enum ToastTiming {
    public static let shortDuration: TimeInterval = 3.0
    public static let undoDuration: TimeInterval = 5.0
    public static let voiceOverDuration: TimeInterval = 20.0
}

public struct ToastMessage: Identifiable, Sendable {
    public let id: UUID
    public let text: String
    public let systemImage: String?
    public let duration: TimeInterval
    public let undoHandler: (@MainActor @Sendable () -> Void)?

    public init(
        id: UUID = UUID(),
        text: String,
        systemImage: String? = nil,
        duration: TimeInterval? = nil,
        isVoiceOverRunning: Bool = false,
        undo: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.id = id
        self.text = text
        self.systemImage = systemImage
        self.undoHandler = undo
        if let duration {
            self.duration = duration
        } else if isVoiceOverRunning {
            self.duration = ToastTiming.voiceOverDuration
        } else if undo != nil {
            self.duration = ToastTiming.undoDuration
        } else {
            self.duration = ToastTiming.shortDuration
        }
    }
}

/// Queueing, auto-dismiss, pause-on-touch, and undo toast engine.
@MainActor
@Observable
public final class ToastCenter {
    public private(set) var current: ToastMessage?
    public private(set) var queue: [ToastMessage] = []
    public private(set) var isPaused = false

    private var dismissTask: Task<Void, Never>?

    public init() {}

    public func show(
        _ text: String,
        systemImage: String? = nil,
        isVoiceOverRunning: Bool = false,
        undo: (@MainActor @Sendable () -> Void)? = nil
    ) {
        let message = ToastMessage(
            text: text,
            systemImage: systemImage,
            isVoiceOverRunning: isVoiceOverRunning,
            undo: undo
        )
        if current == nil {
            present(message)
        } else {
            queue.append(message)
        }
    }

    public func pause() {
        isPaused = true
        dismissTask?.cancel()
        dismissTask = nil
    }

    public func resume() {
        guard isPaused else { return }
        isPaused = false
        if let current {
            scheduleDismiss(after: current.duration, id: current.id)
        }
    }

    public func triggerUndo() {
        guard let handler = current?.undoHandler else { return }
        dismiss()
        handler()
    }

    public func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        current = nil
        isPaused = false
        if !queue.isEmpty {
            let next = queue.removeFirst()
            present(next)
        }
    }

    private func present(_ message: ToastMessage) {
        current = message
        if !isPaused {
            scheduleDismiss(after: message.duration, id: message.id)
        }
    }

    private func scheduleDismiss(after duration: TimeInterval, id: UUID) {
        dismissTask?.cancel()
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled, let self, self.current?.id == id else { return }
            self.dismiss()
        }
    }
}
