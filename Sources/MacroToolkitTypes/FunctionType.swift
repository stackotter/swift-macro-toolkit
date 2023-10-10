import SwiftSyntax

/// Wraps a function type (e.g. `(Int, Double) -> Bool`).
public struct FunctionType: TypeProtocol {
    // TODO: Should give access to attributes such as `@escaping`.
    public var _baseSyntax: FunctionTypeSyntax
    public var _attributedSyntax: AttributedTypeSyntax?

    /// Don't supply the `attributedSyntax` parameter, use the `attributedSyntax` initializer instead.
    /// It only exists because of protocol conformance.
    public init(_ syntax: FunctionTypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        _baseSyntax = syntax
        _attributedSyntax = attributedSyntax
    }

    /// The return type that the function type describes.
    public var returnType: Type {
        Type(_baseSyntax.returnClause.type)
    }

    /// The types of the parameters the function type describes.
    public var parameters: [Type] {
        _baseSyntax.parameters.map(\.type).map(Type.init)
    }
}
