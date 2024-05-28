import SwiftSyntax

/// Wraps a class restriction type (i.e. `class` in a conformance position). Equivalent to `AnyObject`.
public struct ClassRestrictionType: TypeProtocol {
    public var _baseSyntax: ClassRestrictionTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(
        _ syntax: ClassRestrictionTypeSyntax,
        attributedSyntax: AttributedTypeSyntax? = nil
    ) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }
}
