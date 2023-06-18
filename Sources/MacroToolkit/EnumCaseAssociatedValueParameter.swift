import SwiftSyntax

/// Wraps a function parameter's syntax.
public struct EnumCaseAssociatedValueParameter {
    public var _syntax: EnumCaseParameterSyntax

    public init(_ syntax: EnumCaseParameterSyntax) {
        _syntax = syntax
    }

    /// The external name for the parameter. `nil` if the in-source label is `_`.
    public var label: String? {
        let label = _syntax.firstName?.withoutTrivia().description

        if label == "_" {
            return nil
        } else {
            return label
        }
    }

    /// The internal name for the parameter.
    public var name: String? {
        (_syntax.secondName ?? _syntax.firstName)?.description
    }

    public var type: Type {
        Type(_syntax.type)
    }
}
