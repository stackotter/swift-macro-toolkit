import SwiftSyntax

/// Wraps a member type (e.g. `Array<Int>.Element`).
public struct NormalizedMemberType: TypeProtocol {
    public var _baseSyntax: MemberTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(
        _ syntax: MemberTypeSyntax,
        attributedSyntax: AttributedTypeSyntax? = nil
    ) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
