import SwiftSyntax

public struct Expr {
    public var _syntax: ExprSyntax

    public init(_ syntax: ExprSyntax) {
        _syntax = syntax
    }

    public init(_ syntax: any ExprSyntaxProtocol) {
        _syntax = ExprSyntax(syntax)
    }

    public var asStringLiteral: StringLiteral? {
        StringLiteral(self._syntax)
    }

    public var asBooleanLiteral: BooleanLiteral? {
        BooleanLiteral(self._syntax)
    }

    public var asFloatLiteral: FloatLiteral? {
        FloatLiteral(self._syntax)
    }

    public var asIntegerLiteral: IntegerLiteral? {
        IntegerLiteral(self._syntax)
    }

    public var asNilLiteral: NilLiteral? {
        NilLiteral(self._syntax)
    }

    public var asRegexLiteral: RegexLiteral? {
        RegexLiteral(self._syntax)
    }
}
