#if os(iOS)
import CoreGraphics
import MisotoBehavior
import Testing

struct AppearanceWindowTests {
    @Test func shouldAnimateRequiresVisibleOpaqueWindowWithoutReduceMotion() {
        #expect(AppearanceWindow.shouldAnimate(windowIsHidden: false, alpha: 1, animated: true, reduceMotion: false))
        #expect(!AppearanceWindow.shouldAnimate(windowIsHidden: true, alpha: 1, animated: true, reduceMotion: false))
        #expect(!AppearanceWindow.shouldAnimate(windowIsHidden: false, alpha: 0, animated: true, reduceMotion: false))
        #expect(!AppearanceWindow.shouldAnimate(windowIsHidden: false, alpha: 1, animated: false, reduceMotion: false))
        #expect(!AppearanceWindow.shouldAnimate(windowIsHidden: false, alpha: 1, animated: true, reduceMotion: true))
    }
}
#endif
