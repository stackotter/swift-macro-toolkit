import Foundation
import SwiftSyntax

/// Wraps a floating point literal (e.g. `5.0` or ` -0xF.0f_ep-2_`).
public struct FloatLiteral: LiteralProtocol {
    public var _syntax: FloatLiteralExprSyntax

    /// The syntax node referring to the entire literal, including the negation syntax.
    public var _negationSyntax: PrefixOperatorExprSyntax?

    public init(_ syntax: FloatLiteralExprSyntax) {
        _syntax = syntax
    }

    /// Succeeds if the expression is either a floating point literal or the negation of a floating point literal.
    /// Assumes that the negation operator hasn't been overloaded.
    public init?(_ syntax: any ExprSyntaxProtocol) {
        guard
            let operatorSyntax = syntax.as(PrefixOperatorExprSyntax.self),
            operatorSyntax.operator.tokenKind == .prefixOperator("-"),
            let literalSyntax = operatorSyntax.expression.as(FloatLiteralExprSyntax.self)
        else {
            // Just treat it as a regular integer literal
            guard let literal = syntax.as(FloatLiteralExprSyntax.self).map(Self.init) else {
                return nil
            }
            self = literal
            return
        }
        _syntax = literalSyntax
        _negationSyntax = operatorSyntax
    }

    public var value: Double {
        let string = _syntax.literal.text

        let isHexadecimal: Bool
        let stringWithoutPrefix: String
        switch string.prefix(2) {
            case "0x":
                isHexadecimal = true
                stringWithoutPrefix = String(string.dropFirst(2))
            default:
                isHexadecimal = false
                stringWithoutPrefix = string
        }

        let exponentSeparator: Character = isHexadecimal ? "p" : "e"
        let parts = stringWithoutPrefix.lowercased().split(separator: exponentSeparator)
        guard parts.count <= 2 else {
            fatalError("Float literal cannot contain more than one exponent separator")
        }

        let exponentValue: Int
        if parts.count == 2 {
            // The exponent part is always decimal
            let exponentPart = parts[1]
            let exponentPartWithoutUnderscores = exponentPart.replacingOccurrences(
                of: "_", with: "")
            guard
                exponentPart.first != "_",
                !exponentPart.starts(with: "-_"),
                let exponent = Int(exponentPartWithoutUnderscores)
            else {
                fatalError("Float literal has invalid exponent part: \(string)")
            }
            exponentValue = exponent
        } else {
            exponentValue = 0
        }

        let partsBeforeExponent = parts[0].split(separator: ".")
        guard partsBeforeExponent.count <= 2 else {
            fatalError("Float literal cannot contain more than one decimal point: \(string)")
        }

        // The integer part can contain underscores anywhere except for the first character (which must be a digit).
        let radix = isHexadecimal ? 16 : 10
        let integerPart = partsBeforeExponent[0]
        let integerPartWithoutUnderscores = integerPart.replacingOccurrences(of: "_", with: "")
        guard
            integerPart.first != "_",
            let integerPartValue = Int(integerPartWithoutUnderscores, radix: radix).map(Double.init)
        else {
            fatalError("Float literal has invalid integer part: \(string)")
        }

        let fractionalPartValue: Double
        if partsBeforeExponent.count == 2 {
            // The fractional part can contain underscores anywhere except for the first character (which must be a digit).
            let fractionalPart = partsBeforeExponent[1]
            let fractionalPartWithoutUnderscores = fractionalPart.replacingOccurrences(
                of: "_", with: "")
            guard
                fractionalPart.first != "_",
                let fractionalPartDigitsValue = Int(fractionalPartWithoutUnderscores, radix: radix)
            else {
                fatalError("Float literal has invalid fractional part: \(string)")
            }

            fractionalPartValue =
                Double(fractionalPartDigitsValue)
                / pow(Double(radix), Double(fractionalPartWithoutUnderscores.count))
        } else {
            fractionalPartValue = 0
        }

        let base: Double = isHexadecimal ? 2 : 10
        let multiplier = pow(base, Double(exponentValue))
        let sign: Double = _negationSyntax == nil ? 1 : -1
        return (integerPartValue + fractionalPartValue) * multiplier * sign
    }
}
