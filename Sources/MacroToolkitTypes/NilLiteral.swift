import SwiftSyntax

/// Wraps a `nil` literal (i.e. `nil`).
///
/// A `nil` literal only has one possible value: `nil`. This makes it a `Void` type (which only has one
/// value).
public struct NilLiteral: LiteralProtocol {
    public var _syntax: NilLiteralExprSyntax

    public init(_ syntax: NilLiteralExprSyntax) {
        _syntax = syntax
    }

    public var value: Void {
        Void()
    }
}
