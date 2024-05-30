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
        let type: any TypeProtocol =
            switch self {
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
        let type: any TypeProtocol =
            switch self {
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
        // TODO: Implement proper type normalization
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

    /// Gets whether the type is a void type (i.e. `Void`, `()`, `(Void)`, `((((()))))`, etc.).
    public var isVoid: Bool {
        normalizedDescription == "Void"
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
