#if os(iOS)
import SwiftUI
import UIKit

/// A window above everything the app presents, for a privacy cover or a lock.
///
/// A window of its own rather than an overlay: an overlay stays beneath the app's sheets, dialogs and alerts, and the App
/// Switcher photographs those. A level above alerts covers them all. While it shows, the app beneath is hidden from
/// VoiceOver; when asked, it also takes the keyboard, so a field left focused underneath takes no typing.
///
/// It decides only how the window goes up and down. When it shows, and what it draws, stay the app's.
@available(iOSApplicationExtension, unavailable)
@MainActor
public final class CoverWindow {
    /// How the cover treats the app beneath. Unified across apps, keeping only genuinely purposeful flags.
    public struct Options: Sendable, Equatable {
        /// Ends editing in the app's windows when the cover takes the keyboard. Off keeps the focused field, so the
        /// keyboard comes back to it when the cover lifts.
        public var endsEditingBelow: Bool
        /// Gives the hosting view a clear background, for a face that does not fill the screen.
        public var clearsBackground: Bool

        public init(endsEditingBelow: Bool = true, clearsBackground: Bool = true) {
            self.endsEditingBelow = endsEditingBelow
            self.clearsBackground = clearsBackground
        }

        public static let standard = Options()
    }

    /// How the cover fades out.
    public enum Fade {
        /// A SwiftUI animation, through `UIView.animate(_:)`.
        case animation(Animation)
        /// A UIKit duration and curve. A window's alpha animated through a SwiftUI animation can land in one frame where
        /// this form fades.
        case curve(duration: TimeInterval, options: UIView.AnimationOptions)
        /// A UIKit spring: `.smooth(duration:)` is `bounce: 0`.
        case spring(duration: TimeInterval, bounce: CGFloat)
    }

    public let options: Options
    public private(set) var isShowing = false
    private var window: UIWindow?
    /// Whether the cover, while it shows, holds the keyboard.
    private var takesKeyboard = false
    /// The app's key window before the cover took the keyboard.
    private weak var coveredKeyWindow: UIWindow?
    private var backgroundObserver: (any NSObjectProtocol)?

    public init(options: Options = .standard) {
        self.options = options
    }

    /// Whether the window has been built on a scene.
    public var isAttached: Bool { window != nil }

    /// Builds the window on `scene`, once; later calls do nothing. Shows at once if ``show(takingKeyboard:)`` was called
    /// before the scene was known.
    public func attach(to scene: UIWindowScene, root: some View) {
        guard window == nil else { return }
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        let host = UIHostingController(rootView: root)
        if options.clearsBackground { host.view.backgroundColor = .clear }
        window.rootViewController = host
        window.accessibilityViewIsModal = true
        window.isHidden = true
        self.window = window
        if isShowing { raise(takingKeyboard: takesKeyboard) }
    }

    /// Calls `handler` from UIKit's own background notification for the window's scene, posted inside the move to the
    /// background and before iOS takes the App Switcher's picture. Delivered on the main queue, so the main-actor
    /// handler's isolation holds.
    public func onSceneDidEnterBackground(_ handler: @escaping @MainActor () -> Void) {
        guard let scene = window?.windowScene else { return }
        if let backgroundObserver { NotificationCenter.default.removeObserver(backgroundObserver) }
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didEnterBackgroundNotification,
            object: scene,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated { handler() }
        }
    }

    /// Up at once, never faded in: iOS takes the switcher's picture as the scene reaches the background, and a fade would
    /// still be half the app. `takingKeyboard` also makes it the key window.
    public func show(takingKeyboard: Bool) {
        isShowing = true
        takesKeyboard = takingKeyboard
        raise(takingKeyboard: takingKeyboard)
    }

    /// Down, back to the app as it was left: with `fade` (nil under Reduce Motion, or to cut), then `completion` once the
    /// window is hidden. Shown again while it fades, it stays.
    public func hide(fade: Fade?, completion: (@MainActor () -> Void)? = nil) {
        guard isShowing else { return }
        isShowing = false
        guard let window, !window.isHidden else { return }
        for other in others(than: window) { other.accessibilityElementsHidden = false }
        if window.isKeyWindow {
            let fallback = others(than: window).first { !$0.isHidden && $0.windowLevel == .normal }
            (coveredKeyWindow ?? fallback)?.makeKey()
        }
        coveredKeyWindow = nil
        let finish = { [weak self] in
            guard let self, !self.isShowing else { return }
            window.isHidden = true
            window.alpha = 1
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            completion?()
        }
        switch fade {
        case nil:
            finish()
        case .animation(let animation):
            UIView.animate(animation) {
                window.alpha = 0
            } completion: {
                finish()
            }
        case .spring(let duration, let bounce):
            UIView.animate(springDuration: duration, bounce: bounce) {
                window.alpha = 0
            } completion: { _ in
                finish()
            }
        case .curve(let duration, let curve):
            UIView.animate(withDuration: duration, delay: 0, options: curve) {
                window.alpha = 0
            } completion: { _ in
                finish()
            }
        }
    }

    /// Closes, without animation, whatever the app underneath presented (a sheet, a full-screen cover, an alert), then
    /// calls `done`: nothing of it may show as the cover lifts.
    public func dismissCoveredPresentations(then done: @escaping () -> Void) {
        let root = (coveredKeyWindow ?? window.flatMap { others(than: $0).first })?.rootViewController
        guard let root, root.presentedViewController != nil else { return done() }
        root.dismiss(animated: false, completion: done)
    }

    private func raise(takingKeyboard: Bool) {
        guard let window else { return }
        let others = others(than: window)
        window.layer.removeAllAnimations()
        window.alpha = 1
        window.isHidden = false
        window.layoutIfNeeded()
        // Handed to the render server now, not at the end of this run loop turn, which may come after the picture.
        CATransaction.flush()
        for other in others { other.accessibilityElementsHidden = true }
        guard takingKeyboard, !window.isKeyWindow else { return }
        coveredKeyWindow = others.first(where: \.isKeyWindow) ?? others.first
        if options.endsEditingBelow { others.forEach { $0.endEditing(true) } }
        window.makeKey()
        UIAccessibility.post(notification: .screenChanged, argument: window.rootViewController?.view)
    }

    private func others(than window: UIWindow) -> [UIWindow] {
        window.windowScene?.windows.filter { $0 !== window } ?? []
    }
}
#endif
