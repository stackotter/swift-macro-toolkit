import SwiftSyntax

/// Wraps a `struct` declaration.
public struct Struct: DeclGroupProtocol {
    /// The underlying syntax node for the `struct` declaration.
    public var rawValue: StructDeclSyntax

    /// The identifier (name) of the `struct`.
    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    /// Initializes a `Struct` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `struct` declaration.
    public init(_ syntax: StructDeclSyntax) {
        rawValue = syntax
    }
}
