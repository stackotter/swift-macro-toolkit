import SwiftSyntax

/// Wraps a `some` or `any` type (i.e. `any Protocol` or `some Protocol`).
public struct NormalizedSomeOrAnyType: TypeProtocol {
    public var _baseSyntax: SomeOrAnyTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(
        _ syntax: SomeOrAnyTypeSyntax,
        attributedSyntax: AttributedTypeSyntax? = nil
    ) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
