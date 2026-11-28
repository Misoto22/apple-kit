#if os(iOS)
import MisotoBehavior
import MisotoMotion
import Testing
import UIKit

@MainActor
struct TabSwitchFadeTests {
    @MainActor
    private final class StubDelegate: NSObject, UITabBarControllerDelegate {
        var didSelectCalled = false
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            didSelectCalled = true
        }
    }

    @Test func installWrapsDelegateOnceAndForwardsUnhandledSelectors() {
        let tabs = UITabBarController()
        let original = StubDelegate()
        tabs.delegate = original

        TabSwitchFade.install(on: tabs)
        let firstInstalled = tabs.delegate
        #expect(firstInstalled is TabSwitchFade)

        TabSwitchFade.install(on: tabs)
        #expect(tabs.delegate === firstInstalled, "install(on:) must be idempotent")

        let child = UIViewController()
        #expect(tabs.delegate?.responds(to: #selector(UITabBarControllerDelegate.tabBarController(_:didSelect:))) == true)
        tabs.delegate?.tabBarController?(tabs, didSelect: child)
        #expect(original.didSelectCalled)

        let animator = tabs.delegate?.tabBarController?(
            tabs,
            animationControllerForTransitionFrom: UIViewController(),
            to: UIViewController()
        )
        #expect(animator?.transitionDuration(using: nil) == Motion.fast)
    }
}
#endif
