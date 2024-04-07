import SwiftSyntax
import SwiftSyntaxBuilder

// TODO: Implement type normalisation and pretend sugar doesn't exist (e.g. Int? looks like Optional<Int> to devs)
/// Wraps type syntax (e.g. `Result<Success, Failure>`).
public enum `Type`: TypeProtocol, SyntaxExpressibleByStringInterpolation {
    /// An array type (e.g. `[Int]`).
    case array(ArrayType)
    /// A `class` token in a conformance list. Equivalent to `AnyObject`.
    case classRestriction(ClassRestrictionType)
    /// A composition of two types (e.g. `Encodable & Decodable`). Used to
    /// combine protocol requirements.
    case composition(CompositionType)
    /// A some or any protocol type (e.g. `any T` or `some T`).
    case someOrAny(SomeOrAnyType)
    /// A dictionary type (e.g. `[Int: String]`).
    case dictionary(DictionaryType)
    /// A function type (e.g. `() -> ()`).
    case function(FunctionType)
    /// An implicitly unwrapped optional type (e.g. `Int!`).
    case implicitlyUnwrappedOptional(ImplicitlyUnwrappedOptionalType)
    /// A member type (e.g. `Array<Int>.Element`).
    case member(MemberType)
    /// A metatype (e.g. `Int.Type` or `Encodable.Protocol`).
    case metatype(MetatypeType)
    /// A placeholder for invalid types that the resilient parser ignored.
    case missing(MissingType)
    /// An optional type (e.g. `Int?`).
    case optional(OptionalType)
    /// A pack expansion type (e.g. `repeat each V`).
    case packExpansion(PackExpansionType)
    /// A pack reference type (e.g. `each V`).
    case packReference(PackReferenceType)
    /// A simple type (e.g. `Int` or `Box<Int>`).
    case simple(SimpleType)
    /// A suppressed type in a conformance position (e.g. `~Copyable`).
    case suppressed(SuppressedType)
    //// A tuple type (e.g. `(Int, String)`).
    case tuple(TupleType)

    public var _baseSyntax: TypeSyntax {
        let type: any TypeProtocol = switch self {
            case .array(let type): type
            case .classRestriction(let type): type
            case .composition(let type): type
            case .someOrAny(let type): type
            case .dictionary(let type): type
            case .function(let type): type
            case .implicitlyUnwrappedOptional(let type): type
            case .member(let type): type
            case .metatype(let type): type
            case .missing(let type): type
            case .optional(let type): type
            case .packExpansion(let type): type
            case .packReference(let type): type
            case .simple(let type): type
            case .suppressed(let type): type
            case .tuple(let type): type
        }
        return TypeSyntax(type._baseSyntax)
    }

    public var _attributedSyntax: AttributedTypeSyntax? {
        let type: any TypeProtocol = switch self {
            case .array(let type): type
            case .classRestriction(let type): type
            case .composition(let type): type
            case .someOrAny(let type): type
            case .dictionary(let type): type
            case .function(let type): type
            case .implicitlyUnwrappedOptional(let type): type
            case .member(let type): type
            case .metatype(let type): type
            case .missing(let type): type
            case .optional(let type): type
            case .packExpansion(let type): type
            case .packReference(let type): type
            case .simple(let type): type
            case .suppressed(let type): type
            case .tuple(let type): type
        }
        return type._attributedSyntax
    }

    /// Wrap a `TypeSyntax` (e.g. `Int?` or `MyStruct<[String]>!`).
    public init(_ syntax: TypeSyntax) {
        self.init(syntax, attributedSyntax: nil)
    }

    public init(_ syntax: TypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        // TODO: Move this weird initializer to an internal protocol if possible
        let syntax: TypeSyntaxProtocol = attributedSyntax ?? syntax
        if let type = ArrayType(syntax) {
            self = .array(type)
        } else if let type = ClassRestrictionType(syntax) {
            self = .classRestriction(type)
        } else if let type = CompositionType(syntax) {
            self = .composition(type)
        } else if let type = SomeOrAnyType(syntax) {
            self = .someOrAny(type)
        } else if let type = DictionaryType(syntax) {
            self = .dictionary(type)
        } else if let type = FunctionType(syntax) {
            self = .function(type)
        } else if let type = ImplicitlyUnwrappedOptionalType(syntax) {
            self = .implicitlyUnwrappedOptional(type)
        } else if let type = MemberType(syntax) {
            self = .member(type)
        } else if let type = MetatypeType(syntax) {
            self = .metatype(type)
        } else if let type = MissingType(syntax) {
            self = .missing(type)
        } else if let type = OptionalType(syntax) {
            self = .optional(type)
        } else if let type = PackExpansionType(syntax) {
            self = .packExpansion(type)
        } else if let type = PackReferenceType(syntax) {
            self = .packReference(type)
        } else if let type = SimpleType(syntax) {
            self = .simple(type)
        } else if let type = SuppressedType(syntax) {
            self = .suppressed(type)
        } else if let type = TupleType(syntax) {
            self = .tuple(type)
        } else {
            fatalError("TODO: Implement wrappers for all types of type syntax")
        }
    }

    // TODO: add an optional version to all type syntax wrappers maybe?
    /// Allows string interpolation syntax to be used to express type syntax.
    public init(stringInterpolation: SyntaxStringInterpolation) {
        self.init(TypeSyntax(stringInterpolation: stringInterpolation))
    }

    /// A normalized description of the type (e.g. for `()` this would be `Void`).
    public var normalizedDescription: String {
        self.normalized()._syntax.withoutTrivia().description
    }

    /// Gets whether the type is a void type (i.e. `Void`, `()`, `(Void)`, `((((()))))`, etc.).
    public var isVoid: Bool {
        normalizedDescription == "\(Void.self)"
    }
    
    /// Gets whether the type is optional
    public var isOptional: Bool {
        if case .simple(let normalizedSimpleType) = self.normalized() {
            return normalizedSimpleType.name == "Optional"
        }
        return false
    }

    // TODO: Generate type conversions with macro?
    /// Attempts to get the type as a simple type.
    public var asSimpleType: SimpleType? {
        switch self {
            case .simple(let type): type
            default: nil
        }
    }

    /// Attempts to get the type as a function type.
    public var asFunctionType: FunctionType? {
        switch self {
            case .function(let type): type
            default: nil
        }
    }

    // TODO: Implement rest of conversions
    
    public func normalized() -> NormalizedType {
        switch self {
        case .array(let type):
            var arrayTypeSyntax: ArrayTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            let normalizedElement = Type(arrayTypeSyntax.element).normalized()
            arrayTypeSyntax.element = TypeSyntax(normalizedElement._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(arrayTypeSyntax)
            
            var base = "Array<\(arrayTypeSyntax.element)>"
            if let attributedTypeSyntax {
                base = base.addingAttributes(from: attributedTypeSyntax)
            }
            return NormalizedType(stringLiteral: base)
        case .classRestriction(let type):
            // Not handling `_attributedSyntax` because `classRestriction` cannot have any attribute
            
            // let normalizedType: NormalizedType = "AnyObject"
            let normalizedType: NormalizedType = .simple(.init(.init(
                leadingTrivia: type._baseSyntax.leadingTrivia,
                name: .identifier("AnyObject"),
                trailingTrivia: type._baseSyntax.trailingTrivia
            )))
            return normalizedType
            
        case .composition(let type):
            // Looks like there can only be simple types in composition, with no generics, and therefore we
            // don't ned to recursively normalize
            
            return .composition(.init(type._baseSyntax, attributedSyntax: type._attributedSyntax))
        case .someOrAny(let type):            
            var someOrAnyTypeSyntax: SomeOrAnyTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            
            let normalizedConstraint = Type(someOrAnyTypeSyntax.constraint).normalized()
            someOrAnyTypeSyntax.constraint = TypeSyntax(normalizedConstraint._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(someOrAnyTypeSyntax)
            
            return .someOrAny(.init(someOrAnyTypeSyntax, attributedSyntax: attributedTypeSyntax))
        case .dictionary(let type):
            var dictionaryTypeSyntax: DictionaryTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            let normalizedKey = Type(dictionaryTypeSyntax.key).normalized()
            let normalizedValue = Type(dictionaryTypeSyntax.value).normalized()
            dictionaryTypeSyntax.key = TypeSyntax(normalizedKey._syntax)
            dictionaryTypeSyntax.value = TypeSyntax(normalizedValue._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(dictionaryTypeSyntax)
            
            var base = "Dictionary<\(dictionaryTypeSyntax.key), \(dictionaryTypeSyntax.value)>"
            if let attributedTypeSyntax {
                base = base.addingAttributes(from: attributedTypeSyntax)
            }
            return NormalizedType(stringLiteral: base)
            
        case .function(let type):
            var functionTypeSyntax: FunctionTypeSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = nil
            if let attributedSyntax = type._attributedSyntax {
                functionTypeSyntax = attributedSyntax.baseType.cast(FunctionTypeSyntax.self)
                attributedTypeSyntax = attributedSyntax
            } else {
                functionTypeSyntax = type._baseSyntax
            }
            let normalizedReturnClause = Type(functionTypeSyntax.returnClause.type).normalized()
            let arrayOfTupleElements = functionTypeSyntax.parameters.map { tupleElement in
                let normalizedType = Type(tupleElement.type).normalized()
                let updatedElementType = TypeSyntax(normalizedType._syntax)
                var newTupleElement = tupleElement
                newTupleElement.type = updatedElementType
                return newTupleElement
            }
            functionTypeSyntax.parameters = .init(arrayOfTupleElements)
            
            functionTypeSyntax.returnClause.type = TypeSyntax(normalizedReturnClause._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(functionTypeSyntax)
                
            return .function(.init(functionTypeSyntax, attributedSyntax: attributedTypeSyntax))
            
        case .implicitlyUnwrappedOptional(let type):
            var implicitlyUnwrappedOptionalTypeSyntax: ImplicitlyUnwrappedOptionalTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            
            let normalizedConstraint = Type(implicitlyUnwrappedOptionalTypeSyntax.wrappedType).normalized()
            implicitlyUnwrappedOptionalTypeSyntax.wrappedType = TypeSyntax(normalizedConstraint._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(implicitlyUnwrappedOptionalTypeSyntax)
            
            return .implicitlyUnwrappedOptional(.init(implicitlyUnwrappedOptionalTypeSyntax, attributedSyntax: attributedTypeSyntax))
            
        case .member(let type):
            var memberTypeSyntax: MemberTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            let normalizedBaseType = Type(type._baseSyntax.baseType).normalized()
            
            memberTypeSyntax.genericArgumentClause = memberTypeSyntax.genericArgumentClause?.normalized()
            
            memberTypeSyntax.baseType = TypeSyntax(normalizedBaseType._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(memberTypeSyntax)
            
            return .member(.init(memberTypeSyntax, attributedSyntax: attributedTypeSyntax))
            
        case .metatype(let type):
            let baseType = type._baseSyntax
            let memberTypeSyntax = MemberTypeSyntax.init(
                leadingTrivia: baseType.leadingTrivia,
                baseType: baseType.baseType,
                name: baseType.metatypeSpecifier,
                trailingTrivia: baseType.trailingTrivia
            )
            if var attributedSyntax = type._attributedSyntax {
                attributedSyntax.baseType = TypeSyntax(memberTypeSyntax)
                return .member(.init(memberTypeSyntax, attributedSyntax: attributedSyntax))
            } else {
                return .member(.init(memberTypeSyntax))
            }
        case .missing(let type):
            return .missing(.init(type._baseSyntax, attributedSyntax: type._attributedSyntax))
        case .optional(let type):
            var optionalTypeSyntax: OptionalTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            let normalizedElement = Type(optionalTypeSyntax.wrappedType).normalized()
            optionalTypeSyntax.wrappedType = TypeSyntax(normalizedElement._syntax)
            attributedTypeSyntax?.baseType = TypeSyntax(optionalTypeSyntax)
            
//            let identifierSyntax = IdentifierTypeSyntax(
//                leadingTrivia: optionalTypeSyntax.leadingTrivia,
//                name: .identifier("Optional"),
//                genericArgumentClause: .init(
//                    arguments: .init(arrayLiteral: .init(argument: optionalTypeSyntax.wrappedType))
//                ),
//                trailingTrivia: optionalTypeSyntax.leadingTrivia
//            )
            
            var base = "Optional<\(optionalTypeSyntax.wrappedType)>"
            if let attributedTypeSyntax {
                base = base.addingAttributes(from: attributedTypeSyntax)
            }
            return NormalizedType(stringLiteral: base)
        case .packExpansion(let type):
            // Looks like there can only be simple identifiers in pack expansions, with no generics, and therefore we
            // don't ned to recursively normalize
            
            return .packExpansion(.init(type._baseSyntax, attributedSyntax: type._attributedSyntax))
        case .packReference(let type):
            // Looks like there can only be simple identifiers in pack references, with no generics, and therefore we
            // don't ned to recursively normalize
            
            return .packReference(.init(type._baseSyntax, attributedSyntax: type._attributedSyntax))
        case .simple(let type):
            if type.name == "Void" {
                // TODO: Add trivia
                return .tuple(.init(.init(elements: [])))
            }
            var identifierTypeSyntax: IdentifierTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            
            identifierTypeSyntax.genericArgumentClause = identifierTypeSyntax.genericArgumentClause?.normalized()
            
            attributedTypeSyntax?.baseType = TypeSyntax(identifierTypeSyntax)
            
            return .simple(.init(identifierTypeSyntax, attributedSyntax: attributedTypeSyntax))
        case .suppressed(let type):
            // Normalizing recursively because it may be needed when https://github.com/apple/swift/issues/62906
            // is fixed. Not handling `_attributedSyntax` because seems like `suppressed` cannot have any attribute
            var suppressedTypeSyntax: SuppressedTypeSyntax = type._baseSyntax
            
            let normalizedConstraint = Type(suppressedTypeSyntax.type).normalized()
            suppressedTypeSyntax.type = TypeSyntax(normalizedConstraint._syntax)
                        
            return .suppressed(.init(suppressedTypeSyntax))
        case .tuple(let type):
            if type.elements.count == 1 {
                let child = type.elements[0]
                if case .tuple(_) = child {
                    return child.normalized()
                }
            }
            
            var tupleTypeSyntax: TupleTypeSyntax = type._baseSyntax
            var attributedTypeSyntax: AttributedTypeSyntax? = type._attributedSyntax
            
            let arrayOfTupleElements = tupleTypeSyntax.elements.map { tupleElement in
                let normalizedType = Type(tupleElement.type).normalized()
                let updatedElementType = TypeSyntax(normalizedType._syntax)
                var newTupleElement = tupleElement
                newTupleElement.type = updatedElementType
                return newTupleElement
            }
            tupleTypeSyntax.elements = .init(arrayOfTupleElements)
            
            attributedTypeSyntax?.baseType = TypeSyntax(tupleTypeSyntax)
            return .tuple(.init(tupleTypeSyntax, attributedSyntax: attributedTypeSyntax))
        }
    }
}

extension Type? {
    /// If `nil`, the type is considered void, otherwise the underlying type is queried (see ``Type/isVoid``).
    public var isVoid: Bool {
        if let self = self {
            return self.isVoid
        } else {
            return true
        }
    }
}

// MARK: Utilities for normalization

fileprivate extension String {
    func addingAttributes(from attributedType: AttributedTypeSyntax) -> String {
        var updatedString = self
        updatedString = "\(attributedType.attributes)\(self)"
        
        if let specifier = attributedType.specifier {
            updatedString = "\(specifier)\(updatedString)"
        }
        
        return updatedString
    }
}

fileprivate extension GenericArgumentClauseSyntax {
    func normalized() -> Self {
        var genericArgumentClause = self
        let arrayOfGenericArgumentClauseArguments = genericArgumentClause.arguments.map { tupleElement in
            let normalizedType = Type(tupleElement.argument).normalized()
            let updatedElementType = TypeSyntax(normalizedType._syntax)
            var newTupleElement = tupleElement
            newTupleElement.argument = updatedElementType
            return newTupleElement
        }
        genericArgumentClause.arguments = .init(arrayOfGenericArgumentClauseArguments)
        return genericArgumentClause
    }
}
