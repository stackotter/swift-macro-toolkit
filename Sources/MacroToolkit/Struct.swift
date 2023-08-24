import SwiftSyntax

/// Wraps a `struct` declaration.
public struct Struct {
    /// The underlying syntax node.
    public var _syntax: StructDeclSyntax

    /// Wraps a syntax node.
    public init(_ syntax: StructDeclSyntax) {
        _syntax = syntax
    }

    /// Attempts to get a declaration group as a struct declaration.
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(StructDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    // TODO: Add members property to all declgroupsyntax decls through protocol default impl
    /// The struct's members.
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }

    /// Types that the struct conforms to.
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }

    /// Whether the `struct` was declared with the `public` access level modifier.
    public var isPublic: Bool {
        _syntax.isPublic
    }
}
