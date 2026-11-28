#if os(iOS)
import MisotoMotion
import SwiftUI
import UIKit

/// Window-level light/dark appearance switching with crossfade, avoiding SwiftUI's `.preferredColorScheme` defects
/// (leaked appearance across alerts, sheets, and status bar transitions).
@available(iOSApplicationExtension, unavailable)
@MainActor
public enum AppearanceWindow {
    /// Whether a cross-dissolve transition should run for a window given its visibility, alpha, flag, and Reduce Motion.
    nonisolated public static func shouldAnimate(
        windowIsHidden: Bool,
        alpha: CGFloat,
        animated: Bool,
        reduceMotion: Bool
    ) -> Bool {
        animated && !reduceMotion && !windowIsHidden && alpha > 0
    }

    /// Applies `style` to every window in `scene`, optionally crossfading visible windows when Reduce Motion is off.
    public static func apply(
        _ style: UIUserInterfaceStyle,
        in scene: UIWindowScene,
        animated: Bool = true
    ) {
        let reduced = ReducedMotion.isOn
        for window in scene.windows {
            guard window.overrideUserInterfaceStyle != style else { continue }
            if shouldAnimate(windowIsHidden: window.isHidden, alpha: window.alpha, animated: animated, reduceMotion: reduced) {
                UIView.transition(
                    with: window,
                    duration: Motion.medium,
                    options: [.transitionCrossDissolve, .allowUserInteraction, .allowAnimatedContent]
                ) {
                    window.overrideUserInterfaceStyle = style
                }
            } else {
                window.overrideUserInterfaceStyle = style
            }
        }
    }

    /// Maps a SwiftUI `ColorScheme?` (`nil` = follow system) to `UIUserInterfaceStyle` and applies it to `scene`.
    public static func apply(
        colorScheme: ColorScheme?,
        in scene: UIWindowScene,
        animated: Bool = true
    ) {
        let style: UIUserInterfaceStyle = switch colorScheme {
        case .light: .light
        case .dark: .dark
        case nil: .unspecified
        @unknown default: .unspecified
        }
        apply(style, in: scene, animated: animated)
    }
}
#endif
