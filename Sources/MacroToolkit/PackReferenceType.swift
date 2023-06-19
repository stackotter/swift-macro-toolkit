import SwiftSyntax

/// Wraps an implicitly unwrapped optional type (e.g. `each V`).
public struct PackReferenceType: TypeProtocol {
    public var _baseSyntax: PackReferenceTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: PackReferenceTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
