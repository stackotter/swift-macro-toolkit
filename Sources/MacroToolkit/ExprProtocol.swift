import SwiftSyntax

public protocol ExprProtocol {
    associatedtype WrappedSyntax: ExprSyntaxProtocol
    var _syntax: WrappedSyntax { get }
    init(_ syntax: WrappedSyntax)
}

extension ExprProtocol {
    public init?(_ syntax: ExprSyntaxProtocol) {
        guard let syntax = syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }

    public init?(_ expr: Expr) {
        guard let syntax = expr._syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }
}
