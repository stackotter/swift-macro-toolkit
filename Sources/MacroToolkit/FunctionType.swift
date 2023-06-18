import SwiftSyntax

/// Wraps a function type (e.g. `(Int, Double) -> Bool`).
public struct FunctionType {
    // TODO: Should give access to attributes such as `@escaping`.
    public var _syntax: FunctionTypeSyntax

    public init?(from other: Type) {
        guard let type = other.asFunctionType else {
            return nil
        }
        self = type
    }

    public init(_ syntax: FunctionTypeSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(FunctionTypeSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public var returnType: Type {
        Type(_syntax.output.returnType)
    }

    public var parameters: [Type] {
        _syntax.arguments.map(\.type).map(Type.init)
    }
}
