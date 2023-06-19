import SwiftSyntax

/// Wraps a member type (e.g. `Foundation.URL`).
public struct MemberType: TypeProtocol {
    public var _baseSyntax: MemberTypeIdentifierSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: MemberTypeIdentifierSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
