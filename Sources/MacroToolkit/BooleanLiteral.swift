import SwiftSyntax

/// Wraps a boolean literal (i.e. `true` or `false`).
public struct BooleanLiteral: LiteralProtocol {
    public var _syntax: BooleanLiteralExprSyntax

    /// Wraps a boolean literal syntax node.
    public init(_ syntax: BooleanLiteralExprSyntax) {
        _syntax = syntax
    }

    public var value: Bool {
        _syntax.literal.tokenKind == .keyword(.true)
    }
}
