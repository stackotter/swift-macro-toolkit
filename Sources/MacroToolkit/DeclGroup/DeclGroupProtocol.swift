import SwiftSyntax

/// A protocol for declaration groups (e.g., `struct`, `class`, `enum`) that can contain members and properties.
/// Declaration groups are higher-level constructs compared to regular declarations such as `var`.
public protocol DeclGroupProtocol: RawRepresentable {
    /// The underlying syntax node for the declaration group.
    var rawValue: RawValue { get }

    /// The declaration's identifier.
    ///
    /// Note: SwiftSyntax's `DeclGroupSyntax` protocol does not include the declaration's identifier.
    /// This must be implemented manually for each declaration wrapper. This omission might be due to
    /// the fact that extensions technically do not have a name, even though they are always attached to a specific identifier.
    var identifier: String { get }

    /// The members of the declaration group.
    var members: [Decl] { get }

    /// The properties declared in the declaration group.
    var properties: [Property] { get }

    /// The inherited types of the declaration group.
    var inheritedTypes: [Type] { get }

    /// Initializes the declaration group with the given syntax node.
    ///
    /// - Parameter syntax: The underlying syntax node representing the declaration group.
    init(_ syntax: RawValue)
}

/// Default implementations and helper initializers for `DeclGroupProtocol`.
extension DeclGroupProtocol {
    /// The underlying syntax node for the declaration group.
    public var _syntax: RawValue {
        rawValue
    }

    /// Initializes the declaration group with the given raw value.
    ///
    /// - Parameter rawValue: The raw value representing the declaration group.
    public init?(rawValue: RawValue) {
        self.init(rawValue)
    }
}

/// Additional functionality for `DeclGroupProtocol` where the raw value conforms to `DeclGroupSyntax`.
extension DeclGroupProtocol where RawValue: DeclGroupSyntax {
    /// Attempts to initialize the wrapper from an arbitrary declaration group.
    ///
    /// - Parameter syntax: The syntax node representing the declaration group.
    /// - Note: This initializer will return `nil` if the syntax node does not match the expected type.
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let rawValue = syntax as? RawValue else { return nil }
        self.init(rawValue: rawValue)
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
        AccessModifier(modifiers: _syntax.modifiers)
    }

    /// The context-specific modifiers of the declaration group.
    public var declarationContext: DeclarationContextModifier? {
        DeclarationContextModifier(modifiers: _syntax.modifiers)
    }
}
