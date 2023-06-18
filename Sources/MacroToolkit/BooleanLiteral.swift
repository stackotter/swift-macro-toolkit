import SwiftSyntax

public struct BooleanLiteral: LiteralProtocol {
    public var _syntax: BooleanLiteralExprSyntax

    public init(_ syntax: BooleanLiteralExprSyntax) {
        _syntax = syntax
    }

    public var value: Bool {
        _syntax.booleanLiteral.tokenKind == .keyword(.true)
    }    
}
