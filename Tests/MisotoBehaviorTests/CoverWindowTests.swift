#if os(iOS)
import Foundation
import MisotoBehavior
import SwiftUI
import Testing
import UIKit

@MainActor
struct CoverWindowTests {
    @Test func standardOptionsAndStateTransitionsWorkBeforeAttach() {
        let cover = CoverWindow()
        #expect(cover.options == .standard)
        #expect(cover.options.endsEditingBelow)
        #expect(cover.options.clearsBackground)
        #expect(!cover.isAttached)
        #expect(!cover.isShowing)
        #expect(!cover.hasBackgroundObserver)

        cover.hide(fade: nil)
        #expect(!cover.isShowing)

        cover.show(takingKeyboard: true)
        #expect(cover.isShowing)

        cover.hide(fade: nil)
        #expect(!cover.isShowing)
    }

    @Test func backgroundObserverClearsOnExplicitRemoval() {
        let cover = CoverWindow()
        cover.onSceneDidEnterBackground {}
        #expect(!cover.hasBackgroundObserver, "Unattached CoverWindow has no scene to observe")
        cover.removeBackgroundObserver()
        #expect(!cover.hasBackgroundObserver)
    }
}
#endif
