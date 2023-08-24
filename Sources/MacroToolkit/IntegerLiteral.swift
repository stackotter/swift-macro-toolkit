import SwiftSyntax

/// Wraps an integer literal (e.g. `1` or `-0xfe`).
public struct IntegerLiteral: LiteralProtocol {
    public var _syntax: IntegerLiteralExprSyntax

    /// The syntax node referring to the entire literal, including the negation syntax.
    public var _negationSyntax: PrefixOperatorExprSyntax?

    public init(_ syntax: IntegerLiteralExprSyntax) {
        _syntax = syntax
    }

    /// Succeeds if the expression is either an integer literal or the negation of an integer literal.
    /// Assumes that the negation operator hasn't been overloaded.
    public init?(_ syntax: any ExprSyntaxProtocol) {
        // TODO: This is a good example for why people should use the toolkit, do you really want to handle negated integer literals yourself?
        //       Floating point literals are an even better example, (`-0xFp-2` anyone?)
        guard
            let operatorSyntax = syntax.as(PrefixOperatorExprSyntax.self),
            operatorSyntax.operator.tokenKind == .prefixOperator("-"),
            let literalSyntax = operatorSyntax.expression.as(IntegerLiteralExprSyntax.self)
        else {
            // Just treat it as a regular integer literal
            guard let literal = syntax.as(IntegerLiteralExprSyntax.self).map(Self.init) else {
                return nil
            }
            self = literal
            return
        }
        _syntax = literalSyntax
        _negationSyntax = operatorSyntax
    }

    public var value: Int {
        let string = _syntax.literal.text

        var prefixCount = 2
        let radix: Int
        switch string.prefix(2) {
            case "0b":
                radix = 2
            case "0o":
                radix = 8
            case "0x":
                radix = 16
            default:
                radix = 10
                prefixCount = 0
        }

        // The rest can contain underscores anywhere except for the first character (which must be a digit).
        let rest = string.dropFirst(prefixCount)
        let restWithoutUnderscores = rest.replacingOccurrences(of: "_", with: "")
        guard
            rest.first != "_",
            let value = Int(restWithoutUnderscores, radix: radix)
        else {
            fatalError("Invalid value for integer literal: \(string)")
        }

        let sign = _negationSyntax == nil ? 1 : -1
        return value * sign
    }
}
