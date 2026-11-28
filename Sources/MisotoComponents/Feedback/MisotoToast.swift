import Foundation
import Observation

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Timing constants matching `tokens/shared/misoto-timing.tokens.json`.
public enum ToastTiming {
    public static let shortDuration: TimeInterval = GeneratedTimingTokens.Toast.shortDuration
    public static let undoDuration: TimeInterval = GeneratedTimingTokens.Toast.undoDuration
    public static let voiceOverDuration: TimeInterval = GeneratedTimingTokens.Toast.voiceOverDuration

    /// Whether the system VoiceOver assistive technology is currently active.
    @MainActor public static var systemIsVoiceOverRunning: Bool {
        #if canImport(UIKit) && !os(watchOS)
        UIAccessibility.isVoiceOverRunning
        #elseif canImport(AppKit)
        NSWorkspace.shared.isVoiceOverEnabled
        #else
        false
        #endif
    }
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

/// Queueing, auto-dismiss, pause-on-touch, and undo toast engine that reads system VoiceOver state automatically
/// when callers omit `isVoiceOverRunning`.
@MainActor
@Observable
public final class ToastCenter {
    public private(set) var current: ToastMessage?
    public private(set) var queue: [ToastMessage] = []
    public private(set) var isPaused = false

    private var dismissTask: Task<Void, Never>?
    private let isVoiceOverRunningProvider: @MainActor () -> Bool

    public init(
        isVoiceOverRunning: @escaping @MainActor () -> Bool = { ToastTiming.systemIsVoiceOverRunning }
    ) {
        self.isVoiceOverRunningProvider = isVoiceOverRunning
    }

    public func show(
        _ text: String,
        systemImage: String? = nil,
        isVoiceOverRunning: Bool? = nil,
        undo: (@MainActor @Sendable () -> Void)? = nil
    ) {
        let voiceOver = isVoiceOverRunning ?? isVoiceOverRunningProvider()
        let message = ToastMessage(
            text: text,
            systemImage: systemImage,
            isVoiceOverRunning: voiceOver,
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
