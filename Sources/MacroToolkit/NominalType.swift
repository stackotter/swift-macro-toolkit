import SwiftSyntax

/// Wraps a nominal type (e.g. `Result<Success, Failure>`).
public struct NominalType {
    public var _syntax: SimpleTypeIdentifierSyntax

    public init?(from other: Type) {
        guard let type = other.asNominalType else {
            return nil
        }
        self = type
    }

    public init(_ syntax: SimpleTypeIdentifierSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(SimpleTypeIdentifierSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public var name: String {
        _syntax.name.description
    }

    public var genericArguments: [Type]? {
        _syntax.genericArgumentClause.map { clause in
            clause.arguments.map(\.argumentType).map(Type.init)
        }
    }
}
