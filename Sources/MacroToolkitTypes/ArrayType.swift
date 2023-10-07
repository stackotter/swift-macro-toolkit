import SwiftSyntax

/// Wraps an array type (e.g. `[Int]`).
public struct ArrayType: TypeProtocol {
    public var _baseSyntax: ArrayTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: ArrayTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
