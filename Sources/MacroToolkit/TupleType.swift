import SwiftSyntax

/// Wraps a tuple type (e.g. `(Int, String)`).
public struct TupleType: TypeProtocol {
    public var _baseSyntax: TupleTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: TupleTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
