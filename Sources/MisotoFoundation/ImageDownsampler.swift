import CoreGraphics
import Foundation
import ImageIO

/// Single-pass ImageIO thumbnail downsampling that strips metadata and avoids full-resolution decode spikes.
public enum ImageDownsampler {
    /// Decodes `data` into a `CGImage` whose longest edge does not exceed `maxPixelSize`.
    /// Returns `nil` when `data` is not a readable image or `maxPixelSize <= 0`.
    public static func downsample(data: Data, maxPixelSize: Int) -> CGImage? {
        guard maxPixelSize > 0 else { return nil }
        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            return nil
        }
        return downsample(source: source, maxPixelSize: maxPixelSize)
    }

    /// Decodes the image at `url` into a `CGImage` whose longest edge does not exceed `maxPixelSize`.
    public static func downsample(url: URL, maxPixelSize: Int) -> CGImage? {
        guard maxPixelSize > 0 else { return nil }
        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions as CFDictionary) else {
            return nil
        }
        return downsample(source: source, maxPixelSize: maxPixelSize)
    }

    private static func downsample(source: CGImageSource, maxPixelSize: Int) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
