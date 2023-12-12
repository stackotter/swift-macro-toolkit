import SwiftSyntax

/// A declaration group (e.g. a `struct` or `class` rather than a regular
/// declaration such as `var`).
public protocol DeclGroupProtocol {
    /// The type of the underlying syntax node being wrapped.
    associatedtype WrappedSyntax: DeclGroupSyntax
    /// The underlying syntax node.
    var _syntax: WrappedSyntax { get }
    /// The declaration's identifier.
    ///
    /// For some reason SwiftSyntax's `DeclGroupSyntax` protocol doesn't have the
    /// declaration's identifier, so this needs to be implemented manually
    /// for every declaration wrapper. Maybe due to extensions technically not
    /// having a name? (although they're always attached to a specific identifier).
    var identifier: String { get }
    /// Wraps a syntax node.
    init(_ syntax: WrappedSyntax)

}

extension DeclGroupProtocol {
    /// Attempts to initialize the wrapper from an arbitrary decl group (succeeds
    /// if the decl group is the right type of syntax).
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(syntax)
    }

    /// The declaration group's members.
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }

    /// The declaration group's declared properties.
    public var properties: [Property] {
        members.compactMap(\.asVariable).flatMap { variable in
            var bindings = variable._syntax.bindings.flatMap { binding in
                Property.properties(from: binding)
            }
            // For the declaration `var a, b: Int` where `a` doesn't have an annotation,
            // `a` gets given the type of `b` (`Int`). To implement this, we 'drag' the
            // type annotations backwards over the non-annotated bindings.
            var lastSeenType: Type?
            for (i, binding) in bindings.enumerated().reversed() {
                if let type = binding.type {
                    lastSeenType = type
                } else {
                    bindings[i].type = lastSeenType
                }
            }
            return bindings
        }
    }

    /// The types inherited from or conformed to by the decl group. Doesn't
    /// include conformances added by other declaration groups such as an
    /// `extension` of the current declaration.
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }

    // TODO: Replace this with an accessLevel property
    /// Whether the declaration was declared with the `public` access level
    /// modifier.
    public var isPublic: Bool {
        _syntax.isPublic
    }
}
