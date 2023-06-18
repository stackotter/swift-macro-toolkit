import SwiftSyntax

public protocol ExpressionProtocol {
    associatedtype WrappedSyntax: ExprSyntaxProtocol
    var _syntax: WrappedSyntax { get }
    init(_ syntax: WrappedSyntax)
}

extension ExpressionProtocol {
    public init?(_ syntax: ExprSyntaxProtocol) {
        guard let syntax = syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }
}
