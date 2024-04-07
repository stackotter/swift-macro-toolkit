import SwiftSyntax

/// Wraps a composition type (e.g. `ProtocolA & ProtocolB`).
public struct NormalizedCompositionType: TypeProtocol {
    public var _baseSyntax: CompositionTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: CompositionTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
