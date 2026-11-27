import MisotoMotion
import SwiftUI

/// Pinch-to-zoom and double-tap zoom container for photo viewers.
public struct ZoomablePhotoView<Content: View>: View {
    public var minScale: CGFloat
    public var maxScale: CGFloat
    private let content: Content

    @ReduceMotion private var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    public init(
        minScale: CGFloat = 1,
        maxScale: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.minScale = max(1, minScale)
        self.maxScale = max(minScale, maxScale)
        self.content = content()
    }

    public var body: some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .gesture(magnificationGesture)
            .simultaneousGesture(scale > minScale ? dragGesture : nil)
            .onTapGesture(count: 2) {
                let target = scale > minScale ? minScale : min(2.5, maxScale)
                withAnimation(Motion.unless(reduceMotion, Motion.standard)) {
                    scale = target
                    lastScale = target
                    if target == minScale {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let proposed = lastScale * value.magnification
                scale = min(max(proposed, minScale), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= minScale {
                    withAnimation(Motion.unless(reduceMotion, Motion.quick)) {
                        scale = minScale
                        lastScale = minScale
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}
