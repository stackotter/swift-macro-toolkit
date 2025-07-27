import SwiftSyntax

/// An enum case from an enum declaration.
public struct EnumCase {
    public var _syntax: EnumCaseElementSyntax

    public init(_ syntax: EnumCaseElementSyntax, rawRepresentableType: EnumRawRepresentableType? = nil, precedingCase: EnumCase? = nil) {
        _syntax = syntax
        value = if let rawValue = _syntax.rawValue {
            .rawValue(rawValue)
        } else if let associatedValue = _syntax.parameterClause {
            .associatedValue(Array(associatedValue.parameters).map(EnumCaseAssociatedValueParameter.init))
        } else if let rawRepresentableType {
            switch rawRepresentableType {
                case .string: .inferredRawValue(.init(value: "\"\(raw: _syntax.name.text)\"" as ExprSyntax))
                case .character: nil // Characters cannot be inferred
                case .integer, .float: .inferredRawValue(.init(value: "\(raw: (previousValue() ?? -1) + 1)" as ExprSyntax))
            }
        } else {
            nil
        }
        
        /// Raw representable conformance is only synthesized when using integer literals (eg 1), not float literals (eg 1.0).
        func previousValue() -> Int? {
            precedingCase?.rawValue.flatMap(IntegerLiteral.init)?.value
        }
    }

    /// The case's name
    public var identifier: String {
        _syntax.name.withoutTrivia().description
    }
    
    /// The value associated with the enum case (either associated, raw or inferred).
    public var value: EnumCaseValue?
    
    /// Helper that gets the associated values from `EnumCase.value` or returns an empty array.
    public var associatedValues: [EnumCaseAssociatedValueParameter] {
        switch value {
            case .associatedValue(let values): values
            default: []
        }
    }
    
    /// Helper that gets the raw or inferred raw value from `EnumCase.value` or returns nil.
    public var rawValue: ExprSyntax? {
        switch value {
            case .rawValue(let initializer), .inferredRawValue(let initializer): initializer.value
            default: nil
        }
    }
    
    /// Helper that gets the raw or inferred raw value text, eg "value", 1, or 1.0.
    public var rawValueText: String? {
        rawValue.flatMap(StringLiteral.init)?.value.map { "\"\($0)\"" } ??
            rawValue.flatMap(IntegerLiteral.init)?.value.description ??
            rawValue.flatMap(FloatLiteral.init)?.value.description
    }

    public func withoutValue() -> Self {
        EnumCase(_syntax.with(\.rawValue, nil).with(\.parameterClause, nil))
    }
}
