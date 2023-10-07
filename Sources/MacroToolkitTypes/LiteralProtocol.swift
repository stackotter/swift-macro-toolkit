/// A protocol for wrappers of literal syntax (e.g. the wrapper for boolean literals and
/// the wrapper for integer literals).
public protocol LiteralProtocol: ExprProtocol {
    /// The type that the literal defaults to in-code (e.g. `BooleanLiteralExprSyntax`
    /// represents an expression that evaluates to `Bool`, so ``BooleanLiteral`` has
    /// a ``Value`` of `Bool`).
    associatedtype Value
    /// The value of the literal converted to the type it would have in-code.
    var value: Value { get }
}
