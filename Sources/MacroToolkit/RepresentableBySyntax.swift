import SwiftSyntax

/// A protocol that provides a consistent interface for types that are represented by an underlying syntax node.
/// This protocol is useful for working with various SwiftSyntax types in a unified manner.
///
/// Types conforming to this protocol must define an associated `UnderlyingSyntax` type that conforms to `SyntaxProtocol`.
/// They must also provide a `_syntax` property to access the underlying syntax node and an initializer to create an instance from the syntax node.
public protocol RepresentableBySyntax {
    /// The type of the underlying syntax node that this type represents.
    associatedtype UnderlyingSyntax: SyntaxProtocol

    /// The underlying syntax node for this type.
    var _syntax: UnderlyingSyntax { get }

    /// Initializes an instance with the given underlying syntax node.
    ///
    /// - Parameter syntax: The underlying syntax node to represent.
    init(_ syntax: UnderlyingSyntax)
}
