import SwiftSyntax

public struct Struct {
    public var _syntax: StructDeclSyntax

    public init(_ syntax: StructDeclSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(StructDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    // TODO: Add members property to all declgroupsyntax decls through protocol default impl
    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }

    public var inheritedTypes: [Type] {
        _syntax.inheritanceClause?.inheritedTypeCollection.map(\.typeName).map(Type.init) ?? []
    }

    public var isPublic: Bool {
        _syntax.isPublic
    }
}
