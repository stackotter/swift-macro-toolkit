import SwiftSyntax

/// Wraps a suppressed type from a conformance clause (e.g. `~Copyable`).
public struct NormalizedSuppressedType: TypeProtocol {
    public var _baseSyntax: SuppressedTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: SuppressedTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
