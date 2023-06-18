import SwiftSyntax

public struct VariableBinding {
    public var _syntax: PatternBindingSyntax

    public init(_ syntax: PatternBindingSyntax) {
        _syntax = syntax
    }

    public var accessors: [AccessorDeclSyntax] {
        switch _syntax.accessor {
            case .accessors(let block):
                return Array(block.accessors)
            case .getter(let getter):
                // TODO: Avoid synthesising syntax here (wouldn't work with diagnostics)
                return [AccessorDeclSyntax(accessorKind: .keyword(.get), body: getter)]
            case .none:
                return []
        }
    }

    public var identifier: String? {
        _syntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }

    public var type: Type? {
        (_syntax.typeAnnotation?.type).map(Type.init)
    }

    public var initialValue: Expr? {
        (_syntax.initializer?.value).map(Expr.init)
    }
}
