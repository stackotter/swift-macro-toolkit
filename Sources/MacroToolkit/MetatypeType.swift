import SwiftSyntax

/// Wraps a metatype type (e.g. `MyProtocol.Protocol` or `Int.Type`).
public struct MetatypeType: TypeProtocol {
    public var _baseSyntax: MetatypeTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: MetatypeTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
