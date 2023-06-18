import SwiftSyntax

public struct Decl {
    public var _syntax: DeclSyntax

    public init(_ syntax: DeclSyntax) {
        _syntax = syntax
    }

    public init(_ syntax: any DeclSyntaxProtocol) {
        _syntax = DeclSyntax(syntax)
    }

    // TODO: Add conversions for all possible member types
    public var asEnum: Enum? {
        _syntax.as(EnumDeclSyntax.self).map(Enum.init)
    }

    public var asStruct: Struct? {
        _syntax.as(StructDeclSyntax.self).map(Struct.init)
    }

    public var asVariable: Variable? {
        _syntax.as(VariableDeclSyntax.self).map(Variable.init)
    }
}
