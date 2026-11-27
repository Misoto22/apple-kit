import CoreGraphics
import Foundation
import ImageIO
import MisotoFoundation
import Testing
import UniformTypeIdentifiers

struct ImageDownsamplerTests {
    private func makePNGData(width: Int, height: Int) -> Data? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let image = context.makeImage() else {
            return nil
        }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    @Test func downsamplesLongestEdgeWithinLimit() throws {
        let png = try #require(makePNGData(width: 120, height: 60))
        let thumbnail = try #require(ImageDownsampler.downsample(data: png, maxPixelSize: 30))
        #expect(thumbnail.width == 30)
        #expect(thumbnail.height == 15)
    }

    @Test func invalidDataOrNonPositiveSizeReturnsNil() {
        #expect(ImageDownsampler.downsample(data: Data("not-an-image".utf8), maxPixelSize: 100) == nil)
        #expect(ImageDownsampler.downsample(data: Data(), maxPixelSize: 0) == nil)
    }
}
