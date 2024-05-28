import SwiftSyntax

/// Wraps a function parameter's syntax.
public struct FunctionParameter {
    public var _syntax: FunctionParameterSyntax

    public init(_ syntax: FunctionParameterSyntax) {
        _syntax = syntax
    }

    /// - Parameter label: The in-source label to be declared. Use `"_"` to have no ``FunctionParameter/callSiteLabel``.
    public init(label: String? = nil, name: String, type: Type) {
        // TODO: Make the distinction between label and callSiteLabel more clear and well documented
        _syntax = FunctionParameterSyntax(
            firstName: TokenSyntax.identifier(label ?? name),
            secondName: label == nil ? nil : TokenSyntax.identifier(name),
            colon: .colonToken(trailingTrivia: .space),
            type: type._syntax
        )
    }

    /// The explicitly declared label for the parameter. For the label that is used
    /// by callers, see ``FunctionParameter/callSiteLabel``.
    public var label: String? {
        guard _syntax.secondName != nil else {
            return nil
        }
        return _syntax.firstName.withoutTrivia().description
    }

    /// The label used by callers of the function.
    public var callSiteLabel: String? {
        guard let label = label else {
            return name
        }

        if label == "_" {
            return nil
        } else {
            return label
        }
    }

    /// The internal name for the parameter.
    public var name: String {
        (_syntax.secondName ?? _syntax.firstName).description
    }

    public var type: Type {
        Type(_syntax.type)
    }
}

extension Sequence where Element == FunctionParameter {
    /// Converts the sequence into a comma separated parameter list (with each element's
    /// trailing comma updated as needed).
    public var asParameterList: FunctionParameterListSyntax {
        var list = FunctionParameterListSyntax([])
        // TODO: Avoid initializing array just to get count (if possible)
        let parameters = Array(self)
        for (index, parameter) in parameters.enumerated() {
            let isLast = index == parameters.count - 1
            let syntax = parameter._syntax
                .with(\.trailingComma, isLast ? nil : TokenSyntax.commaToken())
            list += [syntax]
        }
        return list
    }

    /// Converts the parameters into an argument list as would be used to passthrough the parameters to
    /// another function with the same parameters (common when wrapping a function).
    public var asPassthroughArguments: [String] {
        // TODO: Make output strongly typed syntax instead of strings
        map { parameter in
            if let label = parameter.callSiteLabel {
                return "\(label): \(parameter.name)"
            }

            return "\(parameter.name)"
        }
    }
}
