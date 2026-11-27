#if os(iOS)
import SwiftUI
import UIKit

/// Delivers the hosting `UIWindowScene` as soon as a SwiftUI view attaches to a window.
@available(iOSApplicationExtension, unavailable)
public struct WindowSceneReader: UIViewRepresentable {
    private let onScene: @MainActor (UIWindowScene) -> Void

    public init(onScene: @escaping @MainActor (UIWindowScene) -> Void) {
        self.onScene = onScene
    }

    public func makeUIView(context: Context) -> SceneProbeView {
        let view = SceneProbeView()
        view.onScene = onScene
        return view
    }

    public func updateUIView(_ uiView: SceneProbeView, context: Context) {
        uiView.onScene = onScene
        uiView.deliverIfAttached()
    }

    @MainActor
    public final class SceneProbeView: UIView {
        var onScene: (@MainActor (UIWindowScene) -> Void)?
        private weak var deliveredScene: UIWindowScene?

        override public func didMoveToWindow() {
            super.didMoveToWindow()
            deliverIfAttached()
        }

        func deliverIfAttached() {
            guard let scene = window?.windowScene, scene !== deliveredScene else { return }
            deliveredScene = scene
            onScene?(scene)
        }
    }
}

extension View {
    /// Delivers the hosting `UIWindowScene` without altering view layout.
    @available(iOSApplicationExtension, unavailable)
    public func readingWindowScene(_ onScene: @escaping @MainActor (UIWindowScene) -> Void) -> some View {
        background(WindowSceneReader(onScene: onScene).frame(width: 0, height: 0).allowsHitTesting(false))
    }
}
#endif
