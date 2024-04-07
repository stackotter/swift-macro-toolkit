import SwiftSyntax
import SwiftSyntaxBuilder

public enum NormalizedType: TypeProtocol, SyntaxExpressibleByStringInterpolation {
    /// A composition of two types (e.g. `Encodable & Decodable`). Used to
    /// combine protocol requirements.
    case composition(NormalizedCompositionType)
    /// A some or any protocol type (e.g. `any T` or `some T`).
    case someOrAny(NormalizedSomeOrAnyType)
    /// A function type (e.g. `() -> ()`).
    case function(NormalizedFunctionType)
    /// An implicitly unwrapped optional type (e.g. `Int!`).
    case implicitlyUnwrappedOptional(NormalizedImplicitlyUnwrappedOptionalType)
    /// A member type (e.g. `Array<Int>.Element`).
    case member(NormalizedMemberType)
    /// A placeholder for invalid types that the resilient parser ignored.
    case missing(NormalizedMissingType)
    /// A pack expansion type (e.g. `repeat each V`).
    case packExpansion(NormalizedPackExpansionType)
    /// A pack reference type (e.g. `each V`).
    case packReference(NormalizedPackReferenceType)
    /// A simple type (e.g. `Int` or `Box<Int>`).
    case simple(NormalizedSimpleType)
    /// A suppressed type in a conformance position (e.g. `~Copyable`).
    case suppressed(NormalizedSuppressedType)
    //// A tuple type (e.g. `(Int, String)`).
    case tuple(NormalizedTupleType)
    
    public var _baseSyntax: TypeSyntax {
        let type: any TypeProtocol = switch self {
        case .composition(let type as any TypeProtocol),
                .someOrAny(let type as any TypeProtocol),
                .function(let type as any TypeProtocol),
                .implicitlyUnwrappedOptional(let type as any TypeProtocol),
                .member(let type as any TypeProtocol),
                .missing(let type as any TypeProtocol),
                .packExpansion(let type as any TypeProtocol),
                .packReference(let type as any TypeProtocol),
                .simple(let type as any TypeProtocol),
                .suppressed(let type as any TypeProtocol),
                .tuple(let type as any TypeProtocol):
            type
        }
        return TypeSyntax(type._baseSyntax)
    }

    public var _attributedSyntax: AttributedTypeSyntax? {
        let type: any TypeProtocol = switch self {
        case .composition(let type as any TypeProtocol),
                .someOrAny(let type as any TypeProtocol),
                .function(let type as any TypeProtocol),
                .implicitlyUnwrappedOptional(let type as any TypeProtocol),
                .member(let type as any TypeProtocol),
                .missing(let type as any TypeProtocol),
                .packExpansion(let type as any TypeProtocol),
                .packReference(let type as any TypeProtocol),
                .simple(let type as any TypeProtocol),
                .suppressed(let type as any TypeProtocol),
                .tuple(let type as any TypeProtocol):
            type
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
        if let type = NormalizedCompositionType(syntax) {
            self = .composition(type)
        } else if let type = NormalizedSomeOrAnyType(syntax) {
            self = .someOrAny(type)
        } else if let type = NormalizedFunctionType(syntax) {
            self = .function(type)
        } else if let type = NormalizedImplicitlyUnwrappedOptionalType(syntax) {
            self = .implicitlyUnwrappedOptional(type)
        } else if let type = NormalizedMemberType(syntax) {
            self = .member(type)
        } else if let type = NormalizedPackExpansionType(syntax) {
            self = .packExpansion(type)
        } else if let type = NormalizedPackReferenceType(syntax) {
            self = .packReference(type)
        } else if let type = NormalizedSimpleType(syntax) {
            self = .simple(type)
        } else if let type = NormalizedSuppressedType(syntax) {
            self = .suppressed(type)
        } else if let type = NormalizedTupleType(syntax) {
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
}
