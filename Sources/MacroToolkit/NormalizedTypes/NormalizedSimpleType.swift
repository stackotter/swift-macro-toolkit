import SwiftSyntax

/// Wraps a simple type (e.g. `Result<Success, Failure>`).
public struct NormalizedSimpleType: TypeProtocol {
    public var _baseSyntax: IdentifierTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(
        _ syntax: IdentifierTypeSyntax,
        attributedSyntax: AttributedTypeSyntax? = nil
    ) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }

    /// The base type's name (e.g. for `Array<Int>` it would be `"Array"`).
    public var name: String {
        _baseSyntax.name.description
    }

    /// The type's generic arguments if any were supplied (e.g. for
    /// `Dictionary<Int, String>` it would be `["Int", "String"]`).
    public var genericArguments: [NormalizedType]? {
        _baseSyntax.genericArgumentClause.map { clause in
            clause.arguments.map(\.argument).map(NormalizedType.init)
        }
    }
}
