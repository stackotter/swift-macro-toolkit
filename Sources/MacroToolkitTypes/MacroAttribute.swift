import SwiftSyntax

// TODO: Combine with ``Attribute``
/// Wraps an attribute in an API more suited to working with macro attributes specifically.
public struct MacroAttribute {
    /// The underlying syntax node.
    public var _syntax: AttributeSyntax

    /// The syntax node representing the attribute's arguments (if any).
    public var _argumentListSyntax: LabeledExprListSyntax? {
        if case let .argumentList(arguments) = _syntax.arguments {
            return arguments
        } else {
            return nil
        }
    }

    /// Wraps a syntax node.
    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    /// Gets the argument with the given label.
    public func argument(labeled label: String) -> Expr? {
        (_argumentListSyntax?.first { element in
            element.label?.text == label
        }?.expression).map(Expr.init)
    }

    // TODO: Add way to conditionally get arguments without labels if no labels are present.
    //   This is required because most of the time when matching against the list of arguments, macro authors will want to ensure there
    //   are no random extraenous labels.
    /// Gets the list of all of the attribute's arguments.
    public var arguments: [(label: String?, expr: Expr)] {
        guard let argumentList = _argumentListSyntax else {
            return []
        }
        return Array(argumentList).map { argument in
            (label: argument.label?.text, expr: Expr(argument.expression))
        }
    }

    /// The attribute's name.
    public var name: Type {
        Type(_syntax.attributeName)
    }
}
