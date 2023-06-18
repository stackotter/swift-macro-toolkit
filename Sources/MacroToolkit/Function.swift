import SwiftSyntax

/// Wraps a function declaration.
public struct Function {
    public var _syntax: FunctionDeclSyntax

    public init?(_ syntax: DeclSyntaxProtocol) {
        guard let syntax = syntax.as(FunctionDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public init(_ syntax: FunctionDeclSyntax) {
        _syntax = syntax
    }

    public var identifier: String {
        _syntax.identifier.text
    }

    public var returnType: Type? {
        (_syntax.signature.output?.returnType).map(Type.init)
    }

    public var returnsVoid: Bool {
        returnType.isVoid
    }

    public var isAsync: Bool {
        _syntax.signature.effectSpecifiers?.asyncSpecifier != nil
    }

    public var isThrowing: Bool {
        _syntax.signature.effectSpecifiers?.throwsSpecifier != nil
    }

    public var parameters: [FunctionParameter] {
        Array(_syntax.signature.input.parameterList).map(FunctionParameter.init)
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
}
