import SwiftSyntax

public struct MacroAttribute {
    public var _syntax: AttributeSyntax

    public var _argumentListSyntax: TupleExprElementListSyntax? {
        if case let .argumentList(arguments) = _syntax.argument {
            return arguments
        } else {
            return nil
        }
    }

    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    public func argument(labeled label: String) -> Expr? {
        (_argumentListSyntax?.first { element in
            return element.label?.text == label
        }?.expression).map(Expr.init)
    }

    public var arguments: [Expr] {
        guard let argumentList = _argumentListSyntax else {
            return []
        }
        return Array(argumentList).map { argument in
            Expr(argument.expression)
        }
    }

    public var name: Type {
        Type(_syntax.attributeName)
    }
}
