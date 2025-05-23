import SwiftSyntax

/// Wraps a missing type (i.e. a type that was missing in the source but the resilient parser
/// has added a placeholder for).
public struct NormalizedMissingType: TypeProtocol {
    public var _baseSyntax: MissingTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: MissingTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
