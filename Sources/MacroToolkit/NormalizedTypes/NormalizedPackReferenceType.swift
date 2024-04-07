import SwiftSyntax

/// Wraps an implicitly unwrapped optional type (e.g. `each V`).
public struct NormalizedPackReferenceType: TypeProtocol {
    public var _baseSyntax: PackElementTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: PackElementTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
