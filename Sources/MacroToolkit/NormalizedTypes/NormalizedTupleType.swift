import SwiftSyntax

/// Wraps a tuple type (e.g. `(Int, String)`).
public struct NormalizedTupleType: TypeProtocol {
    public var _baseSyntax: TupleTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: TupleTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }

    var elements: [NormalizedType] {
        // TODO: Handle labels and the possible ellipsis
        _baseSyntax.elements.map { element in
            NormalizedType(element.type)
        }
    }
}
