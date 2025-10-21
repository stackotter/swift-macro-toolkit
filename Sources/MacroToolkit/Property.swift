import SwiftSyntax

// TODO: Handle all modifiers
// TODO: Make keyword enum-typed instead of stringly-typed
// TODO: Improve attribute API, perhaps with a way to ignore attributes in compiler
//   directive control flow blocks.
// TODO: Implement a way for devs to easily verify the usage of their macros, e.g. not
//   attached to the same decl twice, only attached to static vars, etc.
/// A property of a declaration group such as a `struct`.
public struct Property {
    public var _syntax: TokenSyntax
    public var attributes: [AttributeListElement]
    public var modifiers: [DeclModifierSyntax]
    public var keyword: String
    public var identifier: String
    public var type: Type?
    public var initialValue: Expr?
    public var accessors: [AccessorDeclSyntax]

    public var isLazy: Bool {
        modifiers.contains { $0.name.text == "lazy" }
    }

    public var isStatic: Bool {
        modifiers.contains { $0.name.text == "static" }
    }

    public var getter: AccessorDeclSyntax? {
        accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.get) }
    }

    public var setter: AccessorDeclSyntax? {
        accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.set) }
    }

    public var isStored: Bool {
        getter == nil
    }

    static func properties(
        from binding: PatternBindingSyntax,
        in decl: Variable
    ) -> [Property] {
        let accessors: [AccessorDeclSyntax] =
            switch binding.accessorBlock?.accessors {
                case .accessors(let block):
                    Array(block)
                case .getter(let getter):
                    [AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) { getter }]
                case .none:
                    []
            }
        let attributes: [AttributeListElement] =
            if decl.bindings.count == 1 {
                decl.attributes
            } else {
                []
            }
        return properties(
            pattern: binding.pattern,
            initialValue: (binding.initializer?.value).map(Expr.init),
            type: (binding.typeAnnotation?.type).map(Type.init),
            accessors: accessors,
            attributes: attributes,
            modifiers: Array(decl._syntax.modifiers),
            keyword: decl._syntax.bindingSpecifier.text
        )
    }

    private static func properties(
        pattern: PatternSyntax,
        initialValue: Expr?,
        type: Type?,
        accessors: [AccessorDeclSyntax],
        attributes: [AttributeListElement],
        modifiers: [DeclModifierSyntax],
        keyword: String
    ) -> [Property] {
        switch pattern.asProtocol(PatternSyntaxProtocol.self) {
            case let pattern as IdentifierPatternSyntax:
                let type: Type? =
                    if let type {
                        type
                    } else {
                        if initialValue?.asIntegerLiteral != nil {
                            Type("Int")
                        } else if initialValue?.asFloatLiteral != nil {
                            Type("Double")
                        } else if initialValue?.asStringLiteral != nil {
                            Type("String")
                        } else if initialValue?.asBooleanLiteral != nil {
                            Type("Bool")
                        } else if initialValue?.asRegexLiteral != nil {
                            Type("Regex")
                        } else if let array = initialValue?._syntax.as(ArrayExprSyntax.self) {
                            inferArrayLiteralType(array)
                        } else {
                            nil
                        }
                    }
                return [
                    Property(
                        _syntax: pattern.identifier,
                        attributes: attributes,
                        modifiers: modifiers,
                        keyword: keyword,
                        identifier: pattern.identifier.text,
                        type: type,
                        initialValue: initialValue,
                        accessors: accessors
                    )
                ]
            case let pattern as TuplePatternSyntax:
                let tupleInitialValue: TupleExprSyntax? =
                    if let initialValue, let tuple = initialValue._syntax.as(TupleExprSyntax.self),
                        tuple.elements.count == pattern.elements.count
                    {
                        tuple
                    } else {
                        nil
                    }
                let tupleType: TupleType? =
                    if let type,
                        let tuple = TupleType(type),
                        tuple.elements.count == pattern.elements.count
                    {
                        tuple
                    } else {
                        nil
                    }
                return pattern.elements.enumerated().flatMap { (index, element) in
                    let initialValue =
                        if let tupleInitialValue {
                            Expr(Array(tupleInitialValue.elements)[index].expression)
                        } else {
                            initialValue.map { expr in
                                Expr(
                                    MemberAccessExprSyntax(
                                        leadingTrivia: nil,
                                        base: expr._syntax.parenthesized,
                                        period: .periodToken(),
                                        name: .identifier(String(index)),
                                        trailingTrivia: nil
                                    )
                                )
                            }
                        }

                    // If in a tuple initial value expression, an empty array literal is inferred to have
                    // type `Array<Any>`, unlike with regular initial value expressions.
                    let type =
                        if let arrayLiteral = initialValue?._syntax.as(ArrayExprSyntax.self),
                            arrayLiteral.elements.isEmpty
                        {
                            Type("Array<Any>")
                        } else {
                            tupleType?.elements[index]
                        }

                    // Tuple bindings can't have accessors or attributes (i.e. property wrappers or macros)
                    return properties(
                        pattern: element.pattern,
                        initialValue: initialValue,
                        type: type,
                        accessors: [],
                        attributes: [],
                        modifiers: modifiers,
                        keyword: keyword
                    )
                }
            case _ as WildcardPatternSyntax:
                return []
            default:
                // TODO: Handle all patterns
                return []
        }
    }

    private static func inferArrayLiteralType(_ arrayLiteral: ArrayExprSyntax) -> Type? {
        var elementType: String?
        for element in arrayLiteral.elements {
            if element.expression.is(IntegerLiteralExprSyntax.self) {
                if elementType == nil {
                    elementType = "Int"
                } else if elementType == "Double" {
                    continue
                } else {
                    return nil
                }
            } else if element.expression.is(FloatLiteralExprSyntax.self) {
                if elementType == nil || elementType == "Int" {
                    elementType = "Double"
                } else {
                    return nil
                }
            } else if element.expression.is(BooleanLiteralExprSyntax.self) {
                if elementType == nil {
                    elementType = "Bool"
                } else {
                    return nil
                }
            } else if element.expression.is(StringLiteralExprSyntax.self) {
                if elementType == nil {
                    elementType = "String"
                } else {
                    return nil
                }
            } else if element.expression.is(RegexLiteralExprSyntax.self) {
                if elementType == nil {
                    elementType = "Regex"
                } else {
                    return nil
                }
            }
        }

        return if let elementType {
            Type("Array<\(raw: elementType)>")
        } else {
            nil
        }
    }
}
