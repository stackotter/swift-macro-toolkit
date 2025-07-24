import SwiftSyntax

/// An enum case from an enum declaration.
public struct EnumCase {
    public var _syntax: EnumCaseElementSyntax

    public init(_ syntax: EnumCaseElementSyntax, rawRepresentableType: EnumRawRepresentableType? = nil, precedingCase: EnumCase? = nil) {
        _syntax = syntax
        value = {
            if let rawValue = _syntax.rawValue {
                return .rawValue(rawValue)
            } else if let associatedValue = _syntax.parameterClause {
                let parameters = Array(associatedValue.parameters)
                    .map(EnumCaseAssociatedValueParameter.init)
                return .associatedValue(parameters)
            } else if let rawRepresentableType {
                switch rawRepresentableType {
                case .string: return .inferredRawValue(.init(value: "\"\(raw: _syntax.name.text)\"" as ExprSyntax))
                case .character: return nil // Characters cannot be inferred
                case .number:
                    // Raw representable conformance is only synthesized when using integer literals (eg 1),
                    // not float literals (eg 1.0).
                    let previousValue: Int? = switch precedingCase?.value {
                    case .rawValue(let v), .inferredRawValue(let v): IntegerLiteral(v.value)?.value
                    default: nil
                    }
                    return .inferredRawValue(.init(value: "\(raw: (previousValue ?? -1) + 1)" as ExprSyntax))
                }
            } else {
                return nil
            }
        }()
    }

    /// The case's name
    public var identifier: String {
        _syntax.name.withoutTrivia().description
    }
    
    /// The value associated with the enum case (either associated, raw or inferred).
    public var value: EnumCaseValue?

    public func withoutValue() -> Self {
        EnumCase(_syntax.with(\.rawValue, nil).with(\.parameterClause, nil))
    }
}
