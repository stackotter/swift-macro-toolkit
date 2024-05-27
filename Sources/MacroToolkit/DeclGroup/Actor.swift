import SwiftSyntax

/// Wraps an `actor` declaration.
public struct Actor: DeclGroupProtocol, RepresentableBySyntax {
    /// The underlying syntax node for the `actor` declaration.
    public var _syntax: ActorDeclSyntax

    /// The identifier (name) of the `actor`.
    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    /// Initializes an `Actor` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `actor` declaration.
    public init(_ syntax: ActorDeclSyntax) {
        _syntax = syntax
    }
}
