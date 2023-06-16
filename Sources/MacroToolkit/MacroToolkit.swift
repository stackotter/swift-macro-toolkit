import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MacroError: Error {
    let message: String

    public init(_ message: String) {
        self.message = message
    }
}

extension SyntaxProtocol {
    public func withoutTrivia() -> Self {
        var syntax = self
        syntax.leadingTrivia = []
        syntax.trailingTrivia = []
        return syntax
    }
}

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

    public var returnType: String? {
        _syntax.signature.output?.returnType.withoutTrivia().description
    }

    public var returnsVoid: Bool {
        returnType == "Void" || returnType == nil
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

public enum AttributeListElement {
    case attribute(Attribute)
    case conditionalCompilationBlock(ConditionalCompilationBlock)

    public var attribute: Attribute? {
        switch self {
            case .attribute(let attribute):
                return attribute
            default:
                return nil
        }
    }

    public var conditionalCompilationBlock: ConditionalCompilationBlock? {
        switch self {
            case .conditionalCompilationBlock(let conditionalCompilationBlock):
                return conditionalCompilationBlock
            default:
                return nil
        }
    }
}

public struct ConditionalCompilationBlock {
    public var _syntax: IfConfigDeclSyntax

    public init(_ syntax: IfConfigDeclSyntax) {
        _syntax = syntax
    }
}

public struct FunctionParameter {
    public var _syntax: FunctionParameterSyntax

    public init(_ syntax: FunctionParameterSyntax) {
        _syntax = syntax
    }

    /// The external name for the parameter. `nil` if the in-source label is `_`.
    public var label: String? {
        let label = _syntax.firstName.withoutTrivia().description
        if label == "_" {
            return nil
        } else {
            return label
        }
    }

    /// The internal name for the parameter.
    public var name: String {
        (_syntax.secondName ?? _syntax.firstName).description
    }

    public var type: Type {
        Type(_syntax.type)
    }
}

extension Sequence where Element == FunctionParameter {
    public var asParameterList: FunctionParameterListSyntax {
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

// TODO: Always normalize typed and pretend sugar doesn't exist (e.g. Int? looks like Optional<Int> to devs)
public struct Type {
    public var _syntax: TypeSyntax

    public init(_ syntax: TypeSyntax) {
        _syntax = syntax
    }

    public var _base: TypeSyntax {
        _syntax.as(AttributedTypeSyntax.self)?.baseType ?? _syntax
    }

    public var description: String {
        _syntax.description
    }

    public var normalizedDescription: String {
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

    public var isVoid: Bool {
        normalizedDescription == "Void"
    }

    public var asFunctionType: FunctionType? {
        FunctionType(_base)
    }

    public var asNominalType: NominalType? {
        NominalType(_base)
    }
}

extension Optional<Type> {
    public var isVoid: Bool {
        if let self = self {
            return self.isVoid
        } else {
            return true
        }
    }
}

public struct FunctionType {
    public var _syntax: FunctionTypeSyntax

    public init?(from other: Type) {
        guard let type = other.asFunctionType else {
            return nil
        }
        self = type
    }

    public init(_ syntax: FunctionTypeSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(FunctionTypeSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public var returnType: Type {
        Type(_syntax.output.returnType)
    }

    public var parameters: [Type] {
        _syntax.arguments.map(\.type).map(Type.init)
    }
}

public struct NominalType {
    public var _syntax: SimpleTypeIdentifierSyntax

    public init?(from other: Type) {
        guard let type = other.asNominalType else {
            return nil
        }
        self = type
    }

    public init(_ syntax: SimpleTypeIdentifierSyntax) {
        _syntax = syntax
    }

    public init?(_ syntax: TypeSyntax) {
        guard let syntax = syntax.as(SimpleTypeIdentifierSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public var name: String {
        _syntax.name.description
    }

    public var genericArguments: [Type]? {
        _syntax.genericArgumentClause.map { clause in
            clause.arguments.map(\.argumentType).map(Type.init)
        }
    }
}

public struct Attribute {
    public var _syntax: AttributeSyntax

    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    public var name: Type {
        Type(_syntax.attributeName)
    }
}

extension Sequence where Element == AttributeListElement {
    public var asAttributeList: AttributeListSyntax {
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
    public func removing(_ attribute: AttributeSyntax) -> [AttributeListElement] {
        filter { element in
            element.attribute?._syntax != attribute
        }
    }
}

extension FunctionDeclSyntax {
    public var effectSpecifiersOrDefault: FunctionEffectSpecifiersSyntax {
        signature.effectSpecifiers ?? FunctionEffectSpecifiersSyntax(leadingTrivia: " ", asyncSpecifier: nil, throwsSpecifier: nil)
    }

    public func withAsyncModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
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
    
    public func withThrowsModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
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

    public func withParameters(_ parameters: some Sequence<FunctionParameter>) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.input,
                    ParameterClauseSyntax(parameterList: parameters.asParameterList)
                )
        )
    }

    public func withReturnType(_ type: Type) -> FunctionDeclSyntax {
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

    public func withBody(_ codeBlock: CodeBlockSyntax) -> FunctionDeclSyntax {
        with(
            \.body,
            codeBlock
        )
    }

    public func withAttributes(_ attributes: [AttributeListElement]) -> FunctionDeclSyntax {
        with(
            \.attributes,
            attributes.asAttributeList
        )
    }

    public func withLeadingBlankLine() -> FunctionDeclSyntax {
        with(
            \.leadingTrivia,
            .newlines(2)
        )
    }
}

extension CodeBlockSyntax {
    public init(_ exprs: [ExprSyntax]) {
        self.init(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax(
                exprs.map { expr in
                    CodeBlockItemSyntax(item: .expr(expr))
                }
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
    }
}

// TODO: Figure out a destructuring implementation that uses variadic generics (tricky without same type requirements)
public func destructure<Element>(_ array: [Element]) -> ()? {
    guard array.count == 0 else {
        return nil
    }
    return ()
}

public func destructure<Element>(_ array: [Element]) -> (Element)? {
    guard array.count == 1 else {
        return nil
    }
    return (array[0])
}

public func destructure<Element>(_ array: [Element]) -> (Element, Element)? {
    guard array.count == 2 else {
        return nil
    }
    return (array[0], array[1])
}

public func destructure<Element>(_ array: [Element]) -> (Element, Element, Element)? {
    guard array.count == 3 else {
        return nil
    }
    return (array[0], array[1], array[2])
}

public func destructure<Element>(_ array: [Element]) -> (Element, Element, Element, Element)? {
    guard array.count == 4 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3])
}

public func destructure<Element>(_ array: [Element]) -> (Element, Element, Element, Element, Element)? {
    guard array.count == 5 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3], array[4])
}

public func destructure(_ type: NominalType) -> (String, ())? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: NominalType) -> (String, (Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: NominalType) -> (String, (Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: NominalType) -> (String, (Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: NominalType) -> (String, (Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: NominalType) -> (String, (Type, Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: FunctionType) -> ((), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: Type) -> DestructuredType<()>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public func destructure(_ type: Type) -> DestructuredType<(Type)>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public func destructure(_ type: Type) -> DestructuredType<(Type, Type)>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type)>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type, Type)>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type, Type, Type)>? {
    if let type = type.asNominalType {
        return destructure(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

public enum DestructuredType<TypeList> {
    case nominal(name: String, genericArguments: TypeList)
    case function(parameterTypes: TypeList, returnType: Type)
}