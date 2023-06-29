import SwiftSyntax

/// Wraps a declaration group (a declaration with a scoped block of members).
/// For example an `enum` or a `struct` etc.
public struct DeclGroup {
    /// The underlying syntax node.
    public var _syntax: DeclGroupSyntax

    /// Wraps a declaration group syntax node.
    public init(_ syntax: DeclGroupSyntax) {
        _syntax = syntax
    }

    /// Gets whether the declaration has the `public` access modifier.
    public var isPublic: Bool {
        _syntax.isPublic
    }

    /// Gets all of the declaration group's member declarations.
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }
}
