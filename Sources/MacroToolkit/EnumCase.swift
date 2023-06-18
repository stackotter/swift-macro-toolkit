import SwiftSyntax

/// An enum case from an enum declaration.
public struct EnumCase {
    public var _syntax: EnumCaseElementSyntax

    public init(_ syntax: EnumCaseElementSyntax) {
        _syntax = syntax
    }

    /// The case's name
    public var identifier: String {
        _syntax.identifier.withoutTrivia().description
    }

    /// The value associated with the enum case (either associated or raw).
    public var value: EnumCaseValue? {
        if let rawValue = _syntax.rawValue {
            return .rawValue(rawValue)
        } else if let associatedValue = _syntax.associatedValue {
            let parameters = Array(associatedValue.parameterList)
                .map(EnumCaseAssociatedValueParameter.init)
            return .associatedValue(parameters)
        } else {
            return nil
        }
    }

    public func withoutValue() -> Self {
        EnumCase(_syntax.with(\.rawValue, nil).with(\.associatedValue, nil))
    }
}
