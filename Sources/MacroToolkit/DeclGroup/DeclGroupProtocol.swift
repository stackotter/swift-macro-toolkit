import SwiftSyntax

/// A protocol that represents a declaration group, such as a `struct`, `class`, `enum`, or `protocol`.
/// This protocol defines common properties that all declaration groups should have.
///
/// Conforming types should provide the following properties:
/// - `identifier`: The identifier of the declaration group.
/// - `members`: The members of the declaration group.
/// - `properties`: The properties declared within the declaration group.
/// - `inheritedTypes`: The types that the declaration group inherits from or conforms to.
public protocol AnyDeclGroupProtocol {
    /// The identifier of the declaration group.
    var identifier: String { get }

    /// The members of the declaration group.
    /// This array contains all the members declared within the declaration group.
    var members: [Decl] { get }

    /// The properties declared in the declaration group.
    /// This array contains all the properties declared within the declaration group.
    var properties: [Property] { get }

    /// The inherited types of the declaration group.
    /// This array contains all the types that the declaration group inherits from or conforms to.
    var inheritedTypes: [Type] { get }
}

/// A protocol that represents a declaration group with an underlying syntax node.
/// This protocol extends `AnyDeclGroupProtocol` and `RepresentableBySyntax` to provide additional
/// functionality specific to declaration groups in Swift syntax.
///
/// Conforming types must:
/// - Conform to `AnyDeclGroupProtocol`, providing properties for `identifier`, `members`, `properties`, and `inheritedTypes`.
/// - Conform to `RepresentableBySyntax`, providing an underlying syntax node of type `DeclGroupSyntax`.
public protocol DeclGroupProtocol: AnyDeclGroupProtocol, RepresentableBySyntax
where UnderlyingSyntax: DeclGroupSyntax {}

extension DeclGroupProtocol {
    /// Attempts to initialize the wrapper from an arbitrary declaration group.
    ///
    /// - Parameter syntax: The syntax node representing the declaration group.
    /// - Note: This initializer will return `nil` if the syntax node does not match the expected type.
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax as? UnderlyingSyntax else { return nil }
        self.init(syntax)
    }

    /// The members of the declaration group.
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }

    /// The properties declared in the declaration group.
    public var properties: [Property] {
        members.compactMap(\.asVariable).flatMap { variable in
            var bindings = variable._syntax.bindings.flatMap { binding in
                Property.properties(from: binding, in: variable)
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

    /// The types inherited from or conformed to by the declaration group.
    ///
    /// - Note: This does not include conformances added by other declaration groups such as extensions.
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }

    /// The access level of the declaration group.
    public var accessLevel: AccessModifier? {
        AccessModifier(firstModifierOfKindIn: _syntax.modifiers)
    }

    /// The context-specific modifiers of the declaration group.
    public var declarationContext: DeclarationContextModifier? {
        DeclarationContextModifier(firstModifierOfKindIn: _syntax.modifiers)
    }
}
