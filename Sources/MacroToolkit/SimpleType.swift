import SwiftSyntax

/// Wraps a simple type (e.g. `Result<Success, Failure>`).
public struct SimpleType: TypeProtocol {
    public var _baseSyntax: SimpleTypeIdentifierSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    public init(_ syntax: SimpleTypeIdentifierSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }

    public var name: String {
        _baseSyntax.name.description
    }

    public var genericArguments: [Type]? {
        _baseSyntax.genericArgumentClause.map { clause in
            clause.arguments.map(\.argumentType).map(Type.init)
        }
    }
}
