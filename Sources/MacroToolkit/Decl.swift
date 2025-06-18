import SwiftSyntax

/// A declaration (e.g. an `enum` or a `struct` etc.).
public struct Decl {
    /// The underlying syntax node for the declaration.
    public var _syntax: DeclSyntax

    /// Wraps a declaration syntax node.
    public init(_ syntax: any DeclSyntaxProtocol) {
        _syntax = DeclSyntax(syntax)
    }

    // TODO: Add conversions for all possible member types. Maybe make this into an enum like ``Type``
    /// Attempts to get the declaration as an enum.
    public var asEnum: Enum? {
        _syntax.as(EnumDeclSyntax.self).map(Enum.init)
    }

    /// Attempts to get the declaration as a struct.
    public var asStruct: Struct? {
        _syntax.as(StructDeclSyntax.self).map(Struct.init)
    }

    /// Attempts to get the declaration as a variable.
    public var asVariable: Variable? {
        _syntax.as(VariableDeclSyntax.self).map(Variable.init)
    }
    
    /// Attempts to get the declaration as a function.
    public var asFunction: Function? {
        _syntax.as(FunctionDeclSyntax.self).map(Function.init)
    }
    
    /// Attempts to get the declaration as a associatedtype.
    public var asAssociatedType: AssociatedType? {
        _syntax.as(AssociatedTypeDeclSyntax.self).map(AssociatedType.init)
    }
}
