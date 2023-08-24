import SwiftSyntax

/// Wraps a variable declaration (e.g. `var myVariable: Int = 5`)
public struct Variable {
    /// The underlying syntax node.
    public var _syntax: VariableDeclSyntax

    /// Wraps a syntax node.
    public init(_ syntax: VariableDeclSyntax) {
        _syntax = syntax
    }

    /// Attempts to get an arbitrary declaration as a variable declaration.
    public init?(_ syntax: any DeclSyntaxProtocol) {
        guard let syntax = syntax.as(VariableDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    /// The bindings within the variable declaration. A single variable declaration can
    /// define multiple bindings (e.g. `var a: Int, b: Int`).
    public var bindings: [VariableBinding] {
        _syntax.bindings.map(VariableBinding.init)
    }

    /// All identifiers declared in the variable declaration (can be multiple in cases such
    /// as `var a: Int, b: Int`).
    public var identifiers: [String] {
        bindings.compactMap(\.identifier)
    }

    /// The attributes attached to the variable declaration.
    public var attributes: [AttributeListElement] {
        _syntax.attributes.map { attribute in
            switch attribute {
                case .attribute(let attributeSyntax):
                    return .attribute(Attribute(attributeSyntax))
                case .ifConfigDecl(let ifConfigDeclSyntax):
                    return .conditionalCompilationBlock(
                        ConditionalCompilationBlock(ifConfigDeclSyntax)
                    )
            }
        }
    }

    /// Determines whether the variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    public var isStoredProperty: Bool {
        guard let binding = destructureSingle(bindings) else {
            return false
        }

        for accessor in binding.accessors {
            switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    break
                default:
                    return false
            }
        }
        return true
    }
}
