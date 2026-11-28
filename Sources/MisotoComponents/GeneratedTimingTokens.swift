// Generated from tokens/shared/misoto-timing.tokens.json by tokens/generate-shared.mjs. Do not edit.
import Foundation

internal enum GeneratedTimingTokens {
    enum Toast {
        static let shortDuration: TimeInterval = 3.0
        static let undoDuration: TimeInterval = 5.0
        static let voiceOverDuration: TimeInterval = 20.0
    }

    enum Loading {
        static let placeholderDelay: TimeInterval = 0.4
        static let minimumDisplay: TimeInterval = 0.6
        static let slowThreshold: TimeInterval = 8.0
        static let timeout: TimeInterval = 20.0
    }
}
