import SwiftSyntax

public struct Variable {
    public var _syntax: VariableDeclSyntax

    public init(_ syntax: VariableDeclSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: any DeclSyntaxProtocol) {
        guard let syntax = syntax.as(VariableDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public var bindings: [VariableBinding] {
        _syntax.bindings.map(VariableBinding.init)
    }

    public var identifiers: [String] {
        bindings.compactMap(\.identifier)
    }

    public var attributes: [AttributeListElement] {
        _syntax.attributes.map(Array.init)?.map { attribute in
            switch attribute {
                case .attribute(let attributeSyntax):
                    return .attribute(Attribute(attributeSyntax))
                case .ifConfigDecl(let ifConfigDeclSyntax):
                    return .conditionalCompilationBlock(ConditionalCompilationBlock(ifConfigDeclSyntax))
            }
        } ?? []
    }

    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    public var isStoredProperty: Bool {
        guard let binding = destructureSingle(bindings) else {
            return false
        }

        for accessor in binding.accessors {
            switch accessor.accessorKind.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    break
                default:
                    return false
            }
        }
        return true
    }
}
