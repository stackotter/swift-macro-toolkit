import SwiftSyntax

/// An enumeration representing different types of declaration groups (e.g., `struct`, `class`, `enum`, `actor`, `extension`).
/// This enum conforms to `DeclGroupProtocol` and wraps specific declaration group types.
public enum DeclGroup: DeclGroupProtocol {
    case `struct`(Struct)
    case `enum`(Enum)
    case `class`(Class)
    case actor(Actor)
    case `extension`(Extension)
    
    /// A private computed property that returns the wrapped `DeclGroupProtocol` instance.
    private var wrapped: any DeclGroupProtocol {
        switch self {
        case .struct(let wrapped): return wrapped
        case .enum(let wrapped): return wrapped
        case .class(let wrapped): return wrapped
        case .actor(let wrapped): return wrapped
        case .extension(let wrapped): return wrapped
        }
    }
    
    /// Initializes a `DeclGroup` instance from a `DeclGroupSyntax`.
    ///
    /// - Parameter rawValue: The syntax node representing the declaration group.
    /// - Note: This initializer will fatalError if the syntax node does not match any known declaration group type.
    public init(_ rawValue: any DeclGroupSyntax) {
        switch rawValue {
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
            fatalError("Unhandled decl group type '\(type(of: rawValue))'")
        }
    }
    
    /// The underlying syntax node for the declaration group.
    public var rawValue: any DeclGroupSyntax {
        switch self {
        case .struct(let wrapped): return wrapped.rawValue
        case .enum(let wrapped): return wrapped.rawValue
        case .class(let wrapped): return wrapped.rawValue
        case .actor(let wrapped): return wrapped.rawValue
        case .extension(let wrapped): return wrapped.rawValue
        }
    }
    
    /// The identifier of the declaration group.
    public var identifier: String { wrapped.identifier }
    
    /// The members of the declaration group.
    public var members: [Decl] { wrapped.members }
    
    /// The properties declared in the declaration group.
    public var properties: [Property] { wrapped.properties }
}
