import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension String {
    // The string but with its first character uppercased.
    public var initialUppercased: String {
        guard let initial = first else {
            return self
        }

        return "\(initial.uppercased())\(dropFirst())"
    }
}

extension SyntaxProtocol {
    /// - Returns: The syntax with trivia removed.
    public func withoutTrivia() -> Self {
        var syntax = self
        syntax.leadingTrivia = []
        syntax.trailingTrivia = []
        return syntax
    }
}

/// Wraps an enum declaration.
public struct Enum {
    public var _syntax: EnumDeclSyntax
    
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(EnumDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public init(_ syntax: EnumDeclSyntax) {
        _syntax = syntax
    }

    public var identifier: String {
        _syntax.identifier.withoutTrivia().text
    }

    public var cases: [EnumCase] {
        _syntax.memberBlock.members
            .compactMap { member in
                member.decl.as(EnumCaseDeclSyntax.self)
            }
            .flatMap { syntax in
                syntax.elements.map(EnumCase.init)
            }
    }

    public var isPublic: Bool {
        _syntax.isPublic
    }
}

/// An enum case from an enum declaration.
public struct EnumCase {
    public var _syntax: EnumCaseElementSyntax

    public init(_ syntax: EnumCaseElementSyntax) {
        _syntax = syntax
    }

    /// The case's name
    public var identifier: String {
        _syntax.identifier.withoutTrivia().description
    }

    /// The value associated with the enum case (either associated or raw).
    public var value: EnumCaseValue? {
        if let rawValue = _syntax.rawValue {
            return .rawValue(rawValue)
        } else if let associatedValue = _syntax.associatedValue {
            let parameters = Array(associatedValue.parameterList)
                .map(EnumCaseAssociatedValueParameter.init)
            return .associatedValue(parameters)
        } else {
            return nil
        }
    }

    public func withoutValue() -> Self {
        EnumCase(_syntax.with(\.rawValue, nil).with(\.associatedValue, nil))
    }
}

/// The value associate with a specific enum case declaration.
public enum EnumCaseValue {
    case associatedValue([EnumCaseAssociatedValueParameter])
    case rawValue(InitializerClauseSyntax)
}

/// Wraps a function parameter's syntax.
public struct EnumCaseAssociatedValueParameter {
    public var _syntax: EnumCaseParameterSyntax

    public init(_ syntax: EnumCaseParameterSyntax) {
        _syntax = syntax
    }

    /// The external name for the parameter. `nil` if the in-source label is `_`.
    public var label: String? {
        let label = _syntax.firstName?.withoutTrivia().description

        if label == "_" {
            return nil
        } else {
            return label
        }
    }

    /// The internal name for the parameter.
    public var name: String? {
        (_syntax.secondName ?? _syntax.firstName)?.description
    }

    public var type: Type {
        Type(_syntax.type)
    }
}

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

/// Wraps an element of an attribute list (either an attribute, or a compile-time
/// compilation block containing attributes to be conditionally compiled).
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

/// A compile-time conditional block (i.e. `#if ...`).
public struct ConditionalCompilationBlock {
    public var _syntax: IfConfigDeclSyntax

    public init(_ syntax: IfConfigDeclSyntax) {
        _syntax = syntax
    }
}

/// Wraps a function parameter's syntax.
public struct FunctionParameter {
    public var _syntax: FunctionParameterSyntax

    public init(_ syntax: FunctionParameterSyntax) {
        _syntax = syntax
    }

    /// - Parameter label: The in-source label to be declared. Use `"_"` to have no ``FunctionParameter/callSiteLabel``.
    public init(label: String? = nil, name: String, type: Type) {
        // TODO: Make the distinction between label and callSiteLabel more clear and well documented
        _syntax = FunctionParameterSyntax(
            firstName: TokenSyntax.identifier(label ?? name),
            secondName: label == nil ? nil : TokenSyntax.identifier(name),
            colon: .colonToken(trailingTrivia: .space),
            type: type._syntax
        )
    }

    /// The explicitly declared label for the parameter. For the label that is used
    /// by callers, see ``FunctionParameter/callSiteLabel``.
    public var label: String? {
        guard _syntax.secondName != nil else {
            return nil
        }
        return _syntax.firstName.withoutTrivia().description
    }

    /// The label used by callers of the function.
    public var callSiteLabel: String? {
        guard let label = label else {
            return name
        }

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
    /// Converts the sequence into a comma separated parameter list (with each element's
    /// trailing comma updated as needed).
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

    /// Converts the parameters into an argument list as would be used to passthrough the parameters to
    /// another function with the same parameters (common when wrapping a function).
    public var asPassthroughArguments: [String] {
        // TODO: Make output strongly typed syntax instead of strings
        map { parameter in
            if let label = parameter.callSiteLabel {
                return "\(label): \(parameter.name)"
            }

            return "\(parameter.name)"
        }
    }
}

// TODO: Always normalize typed and pretend sugar doesn't exist (e.g. Int? looks like Optional<Int> to devs)
/// Wraps type syntax (e.g. `Result<Success, Failure>`).
public struct Type: SyntaxExpressibleByStringInterpolation {
    public var _syntax: TypeSyntax

    public init(_ syntax: TypeSyntax) {
        _syntax = syntax
    }

    public init(_ syntax: any TypeSyntaxProtocol) {
        _syntax = TypeSyntax(syntax)
    }

    public init(stringInterpolation: SyntaxStringInterpolation) {
        _syntax = TypeSyntax(stringInterpolation: stringInterpolation)
    }

    public var _base: TypeSyntax {
        _syntax.as(AttributedTypeSyntax.self)?.baseType ?? _syntax
    }

    public var description: String {
        _syntax.withoutTrivia().description
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
    /// If `nil`, the type is considered void, otherwise the underlying type is queried.
    public var isVoid: Bool {
        if let self = self {
            return self.isVoid
        } else {
            return true
        }
    }
}

/// Wraps a function type (e.g. `(Int, Double) -> Bool`).
public struct FunctionType {
    // TODO: Should give access to attributes such as `@escaping`.
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

/// Wraps a nominal type (e.g. `Result<Success, Failure>`).
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

/// Wraps an attribute (e.g. `public` or `@dynamicMemberLookup`).
public struct Attribute {
    public var _syntax: AttributeSyntax

    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    public init(named name: String) {
        _syntax = AttributeSyntax(attributeName: SimpleTypeIdentifierSyntax(
            name: .identifier("DictionaryStorage")
        ))
    }

    public var name: Type {
        Type(_syntax.attributeName)
    }

    public var asMacroAttribute: MacroAttribute? {
        MacroAttribute(_syntax)
    }
}

extension Sequence where Element == AttributeListElement {
    /// Converts the sequence into the syntax for an attribute list (with each element's
    /// trailing trivia updated appropriately).
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

    public func first(called name: String) -> Attribute? {
        // TODO: How should conditional compilation attributes be handled?
        compactMap(\.attribute).first { attribute in
            attribute.name.asNominalType?.name == name
        }
    }
}

extension Collection where Element == AttributeListElement {
    /// Removes any attributes matching the specified attribute, and returns the result.
    public func removing(_ attribute: AttributeSyntax) -> [AttributeListElement] {
        filter { element in
            element.attribute?._syntax != attribute
        }
    }
}

public struct Expression {
    public var _syntax: ExprSyntax

    public init(_ syntax: ExprSyntax) {
        _syntax = syntax
    }

    public init(_ syntax: any ExprSyntaxProtocol) {
        _syntax = ExprSyntax(syntax)
    }

    /// Gets the contents of the expression if it's a string literal with no interpolation.
    public var asSimpleStringLiteral: String? {
        guard
            let literal = _syntax.as(StringLiteralExprSyntax.self),
            literal.segments.count == 1,
            case let .stringSegment(segment)? = literal.segments.first
        else {
            return nil
        }
        return segment.content.text
    }
}

public struct MacroAttribute {
    public var _syntax: AttributeSyntax

    public var _argumentListSyntax: TupleExprElementListSyntax? {
        if case let .argumentList(arguments) = _syntax.argument {
            return arguments
        } else {
            return nil
        }
    }

    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    public func argument(labeled label: String) -> Expression? {
        (_argumentListSyntax?.first { element in
            return element.label?.text == label
        }?.expression).map(Expression.init)
    }

    public var arguments: [Expression] {
        guard let argumentList = _argumentListSyntax else {
            return []
        }
        return Array(argumentList).map { argument in
            Expression(argument.expression)
        }
    }

    public var name: Type {
        Type(_syntax.attributeName)
    }
}

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

public struct VariableBinding {
    public var _syntax: PatternBindingSyntax

    public init(_ syntax: PatternBindingSyntax) {
        _syntax = syntax
    }

    public var accessors: [AccessorDeclSyntax] {
        switch _syntax.accessor {
            case .accessors(let block):
                return Array(block.accessors)
            case .getter(let getter):
                // TODO: Avoid synthesising syntax here (wouldn't work with diagnostics)
                return [AccessorDeclSyntax(accessorKind: .keyword(.get), body: getter)]
            case .none:
                return []
        }
    }

    public var identifier: String? {
        _syntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }

    public var type: Type? {
        (_syntax.typeAnnotation?.type).map(Type.init)
    }

    public var initialValue: Expression? {
        (_syntax.initializer?.value).map(Expression.init)
    }
}

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

public struct DeclGroup {
    public var _syntax: DeclGroupSyntax

    public init(_ syntax: DeclGroupSyntax) {
        _syntax = syntax
    }

    public var isPublic: Bool {
        _syntax.isPublic
    }

    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }
}

extension SyntaxProtocol {
    public func withLeadingNewline() -> Self {
        with(\.leadingTrivia, leadingTrivia + [.newlines(1)])
    }

    public func indented(_ indentation: Indentation = .spaces(4)) -> Self {
        switch indentation {
            case .spaces(let spaces):
                return with(\.leadingTrivia, leadingTrivia + [.spaces(spaces)])
            case .tab:
                return with(\.leadingTrivia, leadingTrivia + [.tabs(1)])
        }
    }
}

public enum Indentation {
    case spaces(Int)
    case tab
}

extension DeclGroupSyntax {
    /// Intended for use in generating user-facing messages. Use a more strongly typed
    /// approach if actually checking the decl kind.
    /// - Parameter article: If `true`, an appropriate article is included before the
    ///   decl kind (e.g. `"a"` or `"an")
    public func textualDeclKind(withArticle article: Bool = false) -> String {
        // Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/MetaEnumMacro.swift#L121
        switch self {
            case is ActorDeclSyntax:
                return article ? "an actor" : "actor"
            case is ClassDeclSyntax:
                return article ? "a class" : "class"
            case is ExtensionDeclSyntax:
                return article ? "an extension" : "extension"
            case is ProtocolDeclSyntax:
                return article ? "a protocol" : "protocol"
            case is StructDeclSyntax:
                return article ? "a struct" : "struct"
            case is EnumDeclSyntax:
                return article ? "an enum" : "enum"
            default:
                return "unknown"
        }
    }
}

extension FunctionDeclSyntax {
    /// Gets the signature's effect specifiers, or returns a default effect specifiers
    /// syntax (without any specifiers).
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

    public func withReturnType(_ type: Type?) -> FunctionDeclSyntax {
        if let type = type {
            return with(
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
        } else {
            return with(\.signature, signature.with(\.output, nil))
        }
    }

    public func withBody(_ codeBlock: CodeBlockSyntax) -> FunctionDeclSyntax {
        with(
            \.body,
            codeBlock
        )
    }

    public func withBody(_ exprs: [ExprSyntax]) -> FunctionDeclSyntax {
        with(
            \.body,
            CodeBlockSyntax(exprs)
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
    /// Creates a code block from an array of expressions.
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

extension DeclGroupSyntax {
    public var isPublic: Bool {
        modifiers?.contains { $0.name.tokenKind == .keyword(.public) } == true
    }
}

// TODO: Figure out a destructuring implementation that uses variadic generics (tricky without same type requirements)
public func destructure<Element>(_ elements: some Sequence<Element>) -> ()? {
    let array = Array(elements)
    guard array.count == 0 else {
        return nil
    }
    return ()
}

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle<Element>(_ elements: some Sequence<Element>) -> (Element)? {
    let array = Array(elements)
    guard array.count == 1 else {
        return nil
    }
    return (array[0])
}

public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element)? {
    let array = Array(elements)
    guard array.count == 2 else {
        return nil
    }
    return (array[0], array[1])
}

public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element, Element)? {
    let array = Array(elements)
    guard array.count == 3 else {
        return nil
    }
    return (array[0], array[1], array[2])
}

public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element, Element, Element)? {
    let array = Array(elements)
    guard array.count == 4 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3])
}

public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element, Element, Element, Element)? {
    let array = Array(elements)
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

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: NominalType) -> (String, (Type))? {
    destructureSingle(type.genericArguments ?? []).map { arguments in
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

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: FunctionType) -> ((Type), Type)? {
    destructureSingle(type.parameters).map { parameters in
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

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: Type) -> DestructuredType<(Type)>? {
    if let type = type.asNominalType {
        return destructureSingle(type).map { destructured in
            .nominal(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructureSingle(type).map { destructured in
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

/// A destructured type (e.g. `Result<Success, Failure>` => `.nominal(name: "Result", genericArguments: ("Success", "Failure"))`).
public enum DestructuredType<TypeList> {
    case nominal(name: String, genericArguments: TypeList)
    case function(parameterTypes: TypeList, returnType: Type)
}