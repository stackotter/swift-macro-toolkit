import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum CustomError: Error {
    case message(String)
}

extension SyntaxProtocol {
    func withoutTrivia() -> Self {
        var syntax = self
        syntax.leadingTrivia = []
        syntax.trailingTrivia = []
        return syntax
    }
}

struct Function {
    var _syntax: FunctionDeclSyntax

    init?(_ syntax: DeclSyntaxProtocol) {
        guard let syntax = syntax.as(FunctionDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    init(_ syntax: FunctionDeclSyntax) {
        _syntax = syntax
    }

    var returnType: String? {
        _syntax.signature.output?.returnType.withoutTrivia().description
    }

    var returnsVoid: Bool {
        returnType == "Void" || returnType == nil
    }

    var isAsync: Bool {
        _syntax.signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var isThrowing: Bool {
        _syntax.signature.effectSpecifiers?.throwsSpecifier != nil
    }

    var parameters: [FunctionParameter] {
        Array(_syntax.signature.input.parameterList).map(FunctionParameter.init)
    }

    var attributes: [AttributeListElement] {
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

enum AttributeListElement {
    case attribute(Attribute)
    case conditionalCompilationBlock(ConditionalCompilationBlock)

    var attribute: Attribute? {
        switch self {
            case .attribute(let attribute):
                return attribute
            default:
                return nil
        }
    }

    var conditionalCompilationBlock: ConditionalCompilationBlock? {
        switch self {
            case .conditionalCompilationBlock(let conditionalCompilationBlock):
                return conditionalCompilationBlock
            default:
                return nil
        }
    }
}

struct ConditionalCompilationBlock {
    var _syntax: IfConfigDeclSyntax

    init(_ syntax: IfConfigDeclSyntax) {
        _syntax = syntax
    }
}

struct FunctionParameter {
    var _syntax: FunctionParameterSyntax

    init(_ syntax: FunctionParameterSyntax) {
        _syntax = syntax
    }

    /// The external name for the parameter. `nil` if the in-source label is `_`.
    var label: String? {
        let label = _syntax.firstName.withoutTrivia().description
        if label == "_" {
            return nil
        } else {
            return label
        }
    }

    /// The internal name for the parameter.
    var name: String {
        (_syntax.secondName ?? _syntax.firstName).description
    }

    var type: Type {
        Type(_syntax.type)
    }
}

extension Sequence where Element == FunctionParameter {
    var asParameterList: FunctionParameterListSyntax {
        var list = FunctionParameterListSyntax([])
        // TODO: Avoid initializing array just to get count (if possible)
        let parameters = Array(self)
        for (index, parameter) in parameters.enumerated() {
            let isLast = index == parameters.count - 1
            let syntax = parameter._syntax.with(\.trailingComma, isLast ? nil : TokenSyntax.commaToken())
            list = list.appending(syntax)
        }
        return list
    }
}

struct Type {
    var _syntax: TypeSyntax

    init(_ syntax: TypeSyntax) {
        _syntax = syntax
    }

    var _base: TypeSyntax {
        _syntax.as(AttributedTypeSyntax.self)?.baseType ?? _syntax
    }

    var description: String {
        _syntax.description
    }

    var normalizedDescription: String {
        // TODO: Normalize types nested within the type too (e.g. the parameter types of a function type)
        if let tupleSyntax = _syntax.as(TupleTypeSyntax.self) {
            if tupleSyntax.elements.count == 0 {
                return "Void"
            } else if tupleSyntax.elements.count == 1, let element = tupleSyntax.elements.first {
                // TODO: Can we assume that we won't get a single-element tuple with a label (which would be invalid anyway)?
                return element.type.withoutTrivia().description
            } else {
                return _syntax.withoutTrivia().description
            }
        } else {
            return _syntax.withoutTrivia().description
        }
    }

    var isVoid: Bool {
        normalizedDescription == "Void"
    }

    var asFunctionType: FunctionType? {
        FunctionType(_base)
    }

    var asNominalType: NominalType? {
        NominalType(_base)
    }
}

extension Optional<Type> {
    var isVoid: Bool {
        if let self = self {
            return self.isVoid
        } else {
            return true
        }
    }
}

struct FunctionType {
    var _syntax: FunctionTypeSyntax

    init(_ syntax: FunctionTypeSyntax) {
        _syntax = syntax
    }

    init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(FunctionTypeSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    var returnType: Type {
        Type(_syntax.output.returnType)
    }

    var parameters: [Type] {
        _syntax.arguments.map(\.type).map(Type.init)
    }
}

struct NominalType {
    var _syntax: SimpleTypeIdentifierSyntax

    init(_ syntax: SimpleTypeIdentifierSyntax) {
        _syntax = syntax
    }

    init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(SimpleTypeIdentifierSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    var name: String {
        _syntax.name.description
    }

    var genericArguments: [Type]? {
        _syntax.genericArgumentClause.map { clause in
            clause.arguments.map(\.argumentType).map(Type.init)
        }
    }
}

struct Attribute {
    var _syntax: AttributeSyntax

    init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    var name: Type {
        Type(_syntax.attributeName)
    }
}

extension Sequence where Element == AttributeListElement {
    var asAttributeList: AttributeListSyntax {
        var list = AttributeListSyntax([])
        for attribute in self {
            let element: AttributeListSyntax.Element
            switch attribute {
                case .attribute(let attribute):
                    element = .attribute(attribute._syntax.with(\.trailingTrivia, [.spaces(1)]))
                case .conditionalCompilationBlock(let conditionalCompilationBlock):
                    element = .ifConfigDecl(conditionalCompilationBlock._syntax.with(\.trailingTrivia, [.spaces(1)]))
            }
            list = list.appending(element)
        }
        return list
    }
}

extension Collection where Element == AttributeListElement {
    func removing(_ attribute: AttributeSyntax) -> [AttributeListElement] {
        filter { element in
            element.attribute?._syntax != attribute
        }
    }
}

extension FunctionDeclSyntax {
    var effectSpecifiersOrDefault: FunctionEffectSpecifiersSyntax {
        signature.effectSpecifiers ?? FunctionEffectSpecifiersSyntax(leadingTrivia: " ", asyncSpecifier: nil, throwsSpecifier: nil)
    }

    func withAsyncModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.effectSpecifiers,
                    effectSpecifiersOrDefault
                        .with(\.asyncSpecifier, isPresent ? " async" : nil)
                )
        )
    }
    
    func withThrowsModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.effectSpecifiers,
                    effectSpecifiersOrDefault
                        .with(\.throwsSpecifier, isPresent ? " throws" : nil)
                )
        )
    }

    func withParameters(_ parameters: some Sequence<FunctionParameter>) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.input,
                    ParameterClauseSyntax(parameterList: parameters.asParameterList)
                )
        )
    }

    func withReturnType(_ type: Type) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.output,
                    ReturnClauseSyntax(
                        leadingTrivia: " ",
                        returnType: type._syntax
                    )
                )
        )        
    }
}

public struct AddAsyncMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {

        // Only on functions at the moment.
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw CustomError.message("@addAsync only works on functions")
        }

        guard let function = Function(declaration) else {
            throw CustomError.message("@addAsync only works on functions")
        }

        // This only makes sense for non async functions.
        if function.isAsync {
            throw CustomError.message(
                "@AddAsync requires a non async function"
            )
        }

        // This only makes sense void functions
        guard function.returnsVoid else {
            throw CustomError.message(
                "@AddAsync requires a function that returns void"
            )
        }

        // Requires a completion handler block as last parameter
        guard
            let completionHandlerType = function.parameters.last?.type.asFunctionType
        else {
            throw CustomError.message(
                "@AddAsync requires a function that has a completion handler as last parameter"
            )
        }

        // Completion handler needs to return Void
        guard completionHandlerType.returnType.isVoid else {
            throw CustomError.message(
                "@AddAsync requires a function that has a completion handler that returns Void"
            )
        }

        guard let returnType = completionHandlerType.parameters.first else {
            throw CustomError.message(
                "@AddAsync requires a function that has a completion handler that has one parameter"
            )
        }

        // TODO: Create type pattern matching/destructuring API
        let successReturnType: Type
        let isResultReturn: Bool
        if let returnType = returnType.asNominalType, returnType.name == "Result", let successType = returnType.genericArguments?.first {
            isResultReturn = true
            successReturnType = successType
        } else {
            isResultReturn = false
            successReturnType = returnType
        }

        // Remove completionHandler and comma from the previous parameter
        let newParameters = function.parameters.dropLast()

        // Drop the @AddAsync attribute from the new declaration.
        let newAttributeList = function.attributes.removing(node)

        let callArguments: [String] = newParameters.map { parameter in
            if let label = parameter.label {
                return "\(label): \(parameter.name)"
            }
            return parameter.name
        }

        let switchBody: ExprSyntax =
            """
            switch returnValue {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
            }
            """

        let newBody: ExprSyntax =
            """
            \(isResultReturn ? "try await withCheckedThrowingContinuation { continuation in" : "await withCheckedContinuation { continuation in")
                \(funcDecl.identifier)(\(raw: callArguments.joined(separator: ", "))) { returnValue in
                    \(isResultReturn ? switchBody : "continuation.resume(returning: returnValue)")
                }
            }
            """

        // TODO: Make better codeblock init
        let newFunc =
            funcDecl
            .withParameters(newParameters)
            .withReturnType(successReturnType)
            .withAsyncModifier()
            .withThrowsModifier(isResultReturn)
            .with(
                \.body,
                CodeBlockSyntax(
                    leftBrace: .leftBraceToken(leadingTrivia: .space),
                    statements: CodeBlockItemListSyntax(
                        [CodeBlockItemSyntax(item: .expr(newBody))]
                    ),
                    rightBrace: .rightBraceToken(leadingTrivia: .newline)
                )
            )
            .with(\.attributes, newAttributeList.asAttributeList)
            .with(\.leadingTrivia, .newlines(2))

        return [DeclSyntax(newFunc)]
    }
}

@main
struct MacroExamplePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddAsyncMacro.self
    ]
}
