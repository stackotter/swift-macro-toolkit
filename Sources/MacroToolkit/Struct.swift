import SwiftSyntax

/// Wraps a `struct` declaration.
public struct Struct: DeclGroupProtocol {
    public var _syntax: StructDeclSyntax

    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    public init(_ syntax: StructDeclSyntax) {
        _syntax = syntax
    }
}
