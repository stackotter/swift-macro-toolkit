import SwiftSyntax

/// Wraps an implicitly unwrapped optional type (e.g. `Int!`).
public struct ImplicitlyUnwrappedOptionalType: TypeProtocol {
    public var _baseSyntax: ImplicitlyUnwrappedOptionalTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(
        _ syntax: ImplicitlyUnwrappedOptionalTypeSyntax,
        attributedSyntax: AttributedTypeSyntax? = nil
    ) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
