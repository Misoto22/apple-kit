#if os(iOS)
import MisotoMotion
import SwiftUI
import UIKit

/// Cross-fades the arriving tab's view in over the outgoing tab's view on `Motion.fast` (`0.15 s`) and
/// `Motion.standardCurve` by wrapping `UITabBarController.delegate` for transitions alone and forwarding every other
/// delegate call back to SwiftUI's delegate.
@MainActor
public final class TabSwitchFade: NSObject, UITabBarControllerDelegate {
    nonisolated(unsafe) private weak var original: UITabBarControllerDelegate?

    private init(original: UITabBarControllerDelegate?) {
        self.original = original
    }

    private static let kept = NSMapTable<UITabBarController, TabSwitchFade>.weakToStrongObjects()

    /// Installs the cross-fade transition delegate on `tabs` idempotently.
    public static func install(on tabs: UITabBarController) {
        guard !(tabs.delegate is TabSwitchFade) else { return }
        let fade = TabSwitchFade(original: tabs.delegate)
        kept.setObject(fade, forKey: tabs)
        tabs.delegate = fade
    }

    public func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        UIView.areAnimationsEnabled ? FadeAnimator() : nil
    }

    override public nonisolated func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || (original?.responds(to: aSelector) ?? false)
    }

    override public nonisolated func forwardingTarget(for aSelector: Selector!) -> Any? {
        original?.responds(to: aSelector) == true ? original : super.forwardingTarget(for: aSelector)
    }

    @MainActor
    private final class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
            Motion.fast
        }

        func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
            guard let toView = transitionContext.view(forKey: .to),
                  let toController = transitionContext.viewController(forKey: .to)
            else {
                return transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            toView.frame = transitionContext.finalFrame(for: toController)
            transitionContext.containerView.addSubview(toView)
            toView.alpha = 0
            let curve = Motion.standardCurve
            let timing = UICubicTimingParameters(
                controlPoint1: CGPoint(x: curve.x1, y: curve.y1),
                controlPoint2: CGPoint(x: curve.x2, y: curve.y2)
            )
            let fade = UIViewPropertyAnimator(
                duration: transitionDuration(using: transitionContext),
                timingParameters: timing
            )
            fade.addAnimations { toView.alpha = 1 }
            fade.addCompletion { _ in
                toView.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            fade.startAnimation()
        }
    }
}

extension View {
    /// Installs `TabSwitchFade` on the enclosing `UITabBarController` once this tab view attaches to a window.
    public func fadingTabSwitches() -> some View {
        background(TabSwitchFadeInstaller().frame(width: 0, height: 0).allowsHitTesting(false).accessibilityHidden(true))
    }
}

private struct TabSwitchFadeInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> ProbeView { ProbeView() }
    func updateUIView(_ uiView: ProbeView, context: Context) { uiView.installIfNeeded() }

    @MainActor
    final class ProbeView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            installIfNeeded()
        }

        func installIfNeeded() {
            guard window != nil else { return }
            var responder: UIResponder? = self
            while let next = responder?.next {
                if let controller = next as? UIViewController, let tabs = controller.tabBarController {
                    TabSwitchFade.install(on: tabs)
                    return
                }
                responder = next
            }
        }
    }
}
#endif
