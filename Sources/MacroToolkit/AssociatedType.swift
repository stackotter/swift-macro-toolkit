import SwiftSyntax

/// Wraps a AssociatedType declaration.
public struct AssociatedType {
    public var _syntax: AssociatedTypeDeclSyntax

    public init?(_ syntax: DeclSyntaxProtocol) {
        guard let syntax = syntax.as(AssociatedTypeDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public init(_ syntax: AssociatedTypeDeclSyntax) {
        _syntax = syntax
    }

    public var identifier: String {
        _syntax.name.text
    }
    
    public var inheritanceClause: String? {
        _syntax.inheritanceClause?.trimmedDescription
    }
    
    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypes.map(\.type).map(Type.init) ?? []
    }
    
    public var genericWhereClauseRequirements: String? {
        _syntax.genericWhereClause?.requirements.trimmedDescription
    }
}
