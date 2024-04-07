import SwiftSyntax

/// Wraps a pack expansion type (e.g. `repeat each V`).
public struct NormalizedPackExpansionType: TypeProtocol {
    public var _baseSyntax: PackExpansionTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: PackExpansionTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
