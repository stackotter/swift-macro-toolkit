import SwiftSyntax

/// An enum that encapsulates various types of declaration groups (`struct`, `class`, `enum`, `actor`, `extension`)
/// and provides a unified interface for interacting with them. This enum conforms to `AnyDeclGroupProtocol`,
/// allowing access to common properties of declaration groups.
public enum AnyDeclGroup: AnyDeclGroupProtocol {
    case `struct`(Struct)
    case `enum`(Enum)
    case `class`(Class)
    case `actor`(Actor)
    case `extension`(Extension)

    /// A private computed property that returns the wrapped `DeclGroupProtocol` instance.
    ///
    /// This property is used internally to access the underlying implementation of the declaration group.
    private var wrapped: any DeclGroupProtocol {
        switch self {
            case .struct(let wrapped): return wrapped
            case .enum(let wrapped): return wrapped
            case .class(let wrapped): return wrapped
            case .actor(let wrapped): return wrapped
            case .extension(let wrapped): return wrapped
        }
    }

    /// Initializes an `AnyDeclGroup` instance from a `DeclGroupSyntax`.
    ///
    /// - Parameter syntax: The syntax node representing the declaration group.
    /// - Note: This initializer will fatalError if the syntax node does not match any known declaration group type.
    public init(_ syntax: DeclGroupSyntax) {
        switch syntax {
            case let syntax as ActorDeclSyntax:
                self = .actor(Actor(syntax))
            case let syntax as ClassDeclSyntax:
                self = .class(Class(syntax))
            case let syntax as EnumDeclSyntax:
                self = .enum(Enum(syntax))
            case let syntax as ExtensionDeclSyntax:
                self = .extension(Extension(syntax))
            case let syntax as StructDeclSyntax:
                self = .struct(Struct(syntax))
            default:
                fatalError("Unhandled decl group type '\(type(of: syntax))'")
        }
    }

    /// The underlying syntax node for the declaration group.
    public var _syntax: DeclGroupSyntax { wrapped._syntax }

    /// The identifier of the declaration group.
    public var identifier: String { wrapped.identifier }

    /// The members of the declaration group.
    public var members: [Decl] { wrapped.members }

    /// The properties declared in the declaration group.
    public var properties: [Property] { wrapped.properties }

    /// The types inherited in the declaration group.
    public var inheritedTypes: [Type] { wrapped.inheritedTypes }
}
