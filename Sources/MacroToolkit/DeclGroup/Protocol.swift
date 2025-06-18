import SwiftSyntax

/// Wraps a `protocol` declaration.
public struct Protocol: DeclGroupProtocol, RepresentableBySyntax {
    /// The underlying syntax node for the `protocol` declaration.
    public var _syntax: ProtocolDeclSyntax

    /// The identifier (name) of the `protocol`.
    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    /// Initializes a `Protocol` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `protocol` declaration.
    public init(_ syntax: ProtocolDeclSyntax) {
        _syntax = syntax
    }
}
