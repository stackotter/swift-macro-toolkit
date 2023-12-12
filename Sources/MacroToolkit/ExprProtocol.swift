import SwiftSyntax

/// A protocol for expression syntax wrappers to conform to. Allows simple conversion between expression wrappers.
public protocol ExprProtocol {
    /// The type of the underlying syntax node being wrapped.
    associatedtype WrappedSyntax: ExprSyntaxProtocol
    /// The underlying syntax node being wrapped.
    var _syntax: WrappedSyntax { get }
    /// Wraps a syntax node.
    init(_ syntax: WrappedSyntax)
}

extension ExprProtocol {
    /// Attempts to initialize the wrapper from an arbitrary expression (succeeds
    /// if the expression is the right type of syntax).
    public init?(_ syntax: any ExprSyntaxProtocol) {
        guard let syntax = syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }

    /// Attempts to initialize the wrapper from an arbitrary expression (succeeds
    /// if the expression is the right type of syntax).
    public init?(_ expr: Expr) {
        guard let syntax = expr._syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }
}
