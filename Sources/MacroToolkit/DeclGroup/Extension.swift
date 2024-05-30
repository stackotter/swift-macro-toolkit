import SwiftSyntax

/// Wraps an `extension` declaration.
public struct Extension: DeclGroupProtocol, RepresentableBySyntax {
    /// The underlying syntax node for the `extension` declaration.
    public var _syntax: ExtensionDeclSyntax

    /// The identifier (extended type) of the `extension`.
    public var identifier: String {
        _syntax.extendedType.withoutTrivia().description
    }

    /// Initializes an `Extension` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `extension` declaration.
    public init(_ syntax: ExtensionDeclSyntax) {
        _syntax = syntax
    }
}
