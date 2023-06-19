import SwiftSyntax
import SwiftSyntaxBuilder

// TODO: Always normalize typed and pretend sugar doesn't exist (e.g. Int? looks like Optional<Int> to devs)
/// Wraps type syntax (e.g. `Result<Success, Failure>`).
public enum Type: TypeProtocol, SyntaxExpressibleByStringInterpolation {
    case array(ArrayType)
    case classRestriction(ClassRestrictionType)
    case composition(CompositionType)
    case constrainedSugar(ConstrainedSugarType)
    case dictionary(DictionaryType)
    case function(FunctionType)
    case implicitlyUnwrappedOptional(ImplicitlyUnwrappedOptionalType)
    case member(MemberType)
    case metatype(MetatypeType)
    case missing(MissingType)
    case optional(OptionalType)
    case packExpansion(PackExpansionType)
    case packReference(PackReferenceType)
    case simple(SimpleType)
    case suppressed(SuppressedType)
    case tuple(TupleType)
    
    public var _baseSyntax: TypeSyntax {
        let type: any TypeProtocol = switch self {
            case .array(let type): type
            case .classRestriction(let type): type
            case .composition(let type): type
            case .constrainedSugar(let type): type
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
            case .constrainedSugar(let type): type
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

    public init(_ syntax: TypeSyntax) {
        self.init(syntax, attributedSyntax: nil)
    }

    /// Ignore the `attributedSyntax` attribute; it exists because of protocol conformance.
    public init(_ syntax: TypeSyntax, attributedSyntax: AttributedTypeSyntax? = nil) {
        // TODO: Move this weird initializer to an internal protocol if possible
        let syntax: TypeSyntaxProtocol = attributedSyntax ?? syntax
        if let type = ArrayType(syntax) {
            self = .array(type)
        } else if let type = ClassRestrictionType(syntax) {
            self = .classRestriction(type)
        } else if let type = CompositionType(syntax) {
            self = .composition(type)
        } else if let type = ConstrainedSugarType(syntax) {
            self = .constrainedSugar(type)
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

    public init(stringInterpolation: SyntaxStringInterpolation) {
        self.init(TypeSyntax(stringInterpolation: stringInterpolation))
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

    // TODO: Generate type conversions with macro?
    public var asSimpleType: SimpleType? {
        switch self {
            case .simple(let type): type
            default: nil
        }
    }

    public var asFunctionType: FunctionType? {
        switch self {
            case .function(let type): type
            default: nil
        }
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
