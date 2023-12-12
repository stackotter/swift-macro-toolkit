import SwiftSyntax

// TODO: Introduce a generic `NumericLiteral` type for both integer and floating point
//   literals, often macro devs might forget to check for integer literals if they just
//   want a floating point number.
// TODO: Create wrapper for tuple syntax
/// Wraps an expression syntax node.
public struct Expr {
    /// The underlying syntax node.
    public var _syntax: ExprSyntax

    /// Wraps a syntax node.
    public init(_ syntax: any ExprSyntaxProtocol) {
        _syntax = ExprSyntax(syntax)
    }

    /// Attempts to get the expression as a string literal.
    public var asStringLiteral: StringLiteral? {
        StringLiteral(self._syntax)
    }

    /// Attempts to get the expression as a boolean literal.
    public var asBooleanLiteral: BooleanLiteral? {
        BooleanLiteral(self._syntax)
    }

    /// Attempts to get the expression as a floating point literal.
    public var asFloatLiteral: FloatLiteral? {
        FloatLiteral(self._syntax)
    }

    /// Attempts to get the expression as an integer literal.
    public var asIntegerLiteral: IntegerLiteral? {
        IntegerLiteral(self._syntax)
    }

    /// Attempts to get the expression as a nil literal.
    public var asNilLiteral: NilLiteral? {
        NilLiteral(self._syntax)
    }

    /// Attempts to get the expression as a regex literal.
    public var asRegexLiteral: RegexLiteral? {
        RegexLiteral(self._syntax)
    }
}
