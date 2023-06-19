import SwiftSyntax

/// Wraps a composition type (e.g. `ProtocolA & ProtocolB`).
public struct CompositionType: TypeProtocol {
    public var _baseSyntax: CompositionTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: CompositionTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
