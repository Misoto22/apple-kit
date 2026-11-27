import SwiftUI

/// A type role supporting system styles and Dynamic-Type-scaled custom fonts.
public struct FontRole: Sendable, Hashable {
    public enum Source: Sendable, Hashable {
        case system(Font.TextStyle, design: Font.Design, weight: Font.Weight)
        case custom(name: String, size: CGFloat, relativeTo: Font.TextStyle, weight: Font.Weight)
    }

    public var source: Source

    public init(source: Source) {
        self.source = source
    }

    public static func system(
        _ style: Font.TextStyle,
        design: Font.Design = .default,
        weight: Font.Weight = .regular
    ) -> FontRole {
        FontRole(source: .system(style, design: design, weight: weight))
    }

    public static func custom(
        _ name: String,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        weight: Font.Weight = .regular
    ) -> FontRole {
        FontRole(source: .custom(name: name, size: size, relativeTo: textStyle, weight: weight))
    }

    /// The resolved SwiftUI `Font` scaling with Dynamic Type.
    public var font: Font {
        switch source {
        case .system(let style, let design, let weight):
            return .system(style, design: design, weight: weight)
        case .custom(let name, let size, let relativeTo, let weight):
            return .custom(name, size: size, relativeTo: relativeTo).weight(weight)
        }
    }
}
