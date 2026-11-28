import CoreGraphics
import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers

@MainActor
enum SnapshotVerifier {
    private static let channelTolerance = 4
    private static let maxDiffRatio = 0.0005

    static var isRecording: Bool {
        ProcessInfo.processInfo.environment["MISOTO_RECORD_SNAPSHOTS"] == "1"
    }

    static var platformFolder: String {
        #if os(macOS)
        "macOS"
        #else
        "iOS"
        #endif
    }

    static func assertSnapshot<V: View>(
        of view: V,
        named name: String,
        filePath: StaticString = #filePath
    ) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        let cgImage = try #require(renderer.cgImage, "ImageRenderer returned nil for \(name)")

        let url = URL(fileURLWithPath: "\(filePath)")
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
            .appendingPathComponent(platformFolder, isDirectory: true)
            .appendingPathComponent("\(name).png")

        if isRecording {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try writePNG(cgImage, to: url)
            return
        }

        let golden = try loadPNG(from: url)
        #expect(cgImage.width == golden.width, "\(name): width \(cgImage.width) != golden \(golden.width)")
        #expect(cgImage.height == golden.height, "\(name): height \(cgImage.height) != golden \(golden.height)")
        guard cgImage.width == golden.width, cgImage.height == golden.height else { return }

        let actualBytes = try rgbaBytes(of: cgImage)
        let goldenBytes = try rgbaBytes(of: golden)
        let pixelCount = cgImage.width * cgImage.height
        var mismatched = 0
        var maxDelta = 0

        for idx in stride(from: 0, to: actualBytes.count, by: 4) {
            let dr = abs(Int(actualBytes[idx]) - Int(goldenBytes[idx]))
            let dg = abs(Int(actualBytes[idx + 1]) - Int(goldenBytes[idx + 1]))
            let db = abs(Int(actualBytes[idx + 2]) - Int(goldenBytes[idx + 2]))
            let da = abs(Int(actualBytes[idx + 3]) - Int(goldenBytes[idx + 3]))
            let delta = max(dr, dg, db, da)
            if delta > maxDelta { maxDelta = delta }
            if delta > channelTolerance {
                mismatched += 1
            }
        }

        let diffRatio = pixelCount > 0 ? Double(mismatched) / Double(pixelCount) : 0
        #expect(
            diffRatio <= maxDiffRatio,
            "\(name): snapshot drifted (\(mismatched)/\(pixelCount) pixels = \(String(format: "%.4f%%", diffRatio * 100)), maxDelta=\(maxDelta)) at \(url.path)"
        )
    }

    private static func writePNG(_ image: CGImage, to url: URL) throws {
        let dest = try #require(
            CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil),
            "Could not create PNG destination at \(url.path)"
        )
        CGImageDestinationAddImage(dest, image, nil)
        let ok = CGImageDestinationFinalize(dest)
        #expect(ok, "Could not finalize PNG at \(url.path)")
    }

    private static func loadPNG(from url: URL) throws -> CGImage {
        let source = try #require(
            CGImageSourceCreateWithURL(url as CFURL, nil),
            "Missing golden snapshot at \(url.path); run with MISOTO_RECORD_SNAPSHOTS=1"
        )
        return try #require(
            CGImageSourceCreateImageAtIndex(source, 0, nil),
            "Unreadable golden PNG at \(url.path)"
        )
    }

    private static func rgbaBytes(of image: CGImage) throws -> [UInt8] {
        let width = image.width
        let height = image.height
        let colorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let ctx = try #require(
            CGContext(
                data: &bytes,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return bytes
    }
}
