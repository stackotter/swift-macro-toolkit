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
    
    /// Initializes the declaration group with the given syntax node.
    ///
    /// - Parameter syntax: The underlying syntax node representing the declaration group.
    init(_ syntax: RawValue)
}

extension DeclGroupProtocol {
    public var _syntax: RawValue {
        get { rawValue }
    }
    
    public init?(rawValue: RawValue) {
        self.init(rawValue)
    }
}

extension DeclGroupProtocol where RawValue: DeclGroupSyntax {
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let rawValue = syntax as? RawValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }
    
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
    
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }
    
    public var accessLevel: AccessModifier? {
        AccessModifier(modifiers: _syntax.modifiers)
    }
    
    public var declarationContext: DeclarationContextModifier? {
        DeclarationContextModifier(modifiers: _syntax.modifiers)
    }
}
