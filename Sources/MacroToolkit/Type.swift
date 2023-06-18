import SwiftSyntax
import SwiftSyntaxBuilder

// TODO: Always normalize typed and pretend sugar doesn't exist (e.g. Int? looks like Optional<Int> to devs)
/// Wraps type syntax (e.g. `Result<Success, Failure>`).
public struct Type: SyntaxExpressibleByStringInterpolation {
    public var _syntax: TypeSyntax

    public init(_ syntax: TypeSyntax) {
        _syntax = syntax
    }

    public init(_ syntax: any TypeSyntaxProtocol) {
        _syntax = TypeSyntax(syntax)
    }

    public init(stringInterpolation: SyntaxStringInterpolation) {
        _syntax = TypeSyntax(stringInterpolation: stringInterpolation)
    }

    public var _base: TypeSyntax {
        _syntax.as(AttributedTypeSyntax.self)?.baseType ?? _syntax
    }

    public var description: String {
        _syntax.withoutTrivia().description
    }

    public var normalizedDescription: String {
        // TODO: Normalize types nested within the type too (e.g. the parameter types of a function type)
        if let tupleSyntax = _syntax.as(TupleTypeSyntax.self) {
            if tupleSyntax.elements.count == 0 {
                return "Void"
            } else if tupleSyntax.elements.count == 1, let element = tupleSyntax.elements.first {
                // TODO: Can we assume that we won't get a single-element tuple with a label (which would be invalid anyway)?
                return element.type.withoutTrivia().description
            } else {
                return _syntax.withoutTrivia().description
            }
        } else {
            return _syntax.withoutTrivia().description
        }
    }

    public var isVoid: Bool {
        normalizedDescription == "Void"
    }

    public var asFunctionType: FunctionType? {
        FunctionType(_base)
    }

    public var asNominalType: NominalType? {
        NominalType(_base)
    }
}

extension Optional<Type> {
    /// If `nil`, the type is considered void, otherwise the underlying type is queried.
    public var isVoid: Bool {
        if let self = self {
            return self.isVoid
        } else {
            return true
        }
    }
}
