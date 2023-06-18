import SwiftSyntax

public struct NilLiteral: LiteralProtocol {
    public var _syntax: NilLiteralExprSyntax

    public init(_ syntax: NilLiteralExprSyntax) {
        _syntax = syntax
    }

    public var value: Void {
        Void()
    } 
}
