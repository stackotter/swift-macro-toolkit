import SwiftSyntax

/// Wraps a constrained sugar type (i.e. `any Protocol` or `some Protocol`).
public struct ConstrainedSugarType: TypeProtocol {
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
