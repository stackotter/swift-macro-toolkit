import SwiftSyntax

/// Wraps a `class` declaration.
public struct Class: DeclGroupProtocol, RepresentableBySyntax {
    /// The underlying syntax node for the `class` declaration.
    public var _syntax: ClassDeclSyntax

    /// The identifier (name) of the `class`.
    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    /// Initializes a `Class` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `class` declaration.
    public init(_ syntax: ClassDeclSyntax) {
        _syntax = syntax
    }
}
