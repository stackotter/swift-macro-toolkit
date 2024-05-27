import SwiftSyntax

/// A protocol that represents a declaration group, such as a `struct`, `class`, `enum`, or `protocol`.
/// This protocol defines common properties that all declaration groups should have.
public protocol DeclGroupProtocol {
    /// The identifier of the declaration group.
    var identifier: String { get }
    
    /// All members declared within the declaration group.
    var members: [Decl] { get }
    
    /// All properties declared within the declaration group.
    var properties: [Property] { get }
    
    /// All types that the declaration group inherits from or conforms to.
    var inheritedTypes: [Type] { get }
}

extension DeclGroupProtocol where UnderlyingSyntax: DeclGroupSyntax, Self: RepresentableBySyntax {
    /// Attempts to initialize the wrapper from an arbitrary declaration group.
    ///
    /// - Parameter syntax: The syntax node representing the declaration group.
    /// - Note: This initializer will return `nil` if the syntax node does not match the expected type.
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax as? UnderlyingSyntax else { return nil }
        self.init(syntax)
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
        AccessModifier(firstModifierOfKindIn: _syntax.modifiers)
    }
    
    public var declarationContext: DeclarationContextModifier? {
        DeclarationContextModifier(firstModifierOfKindIn: _syntax.modifiers)
    }
}
