import SwiftSyntax

/// An enum that encapsulates various types of declaration groups (`struct`, `class`, `enum`, `actor`, `extension`)
/// and provides a unified interface for interacting with them. This enum conforms to `DeclGroupProtocol`,
/// allowing access to common properties of declaration groups.
public enum DeclGroup: DeclGroupProtocol {
    case `struct`(Struct)
    case `enum`(Enum)
    case `class`(Class)
    case `actor`(Actor)
    case `extension`(Extension)
    case `protocol`(Protocol)

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
            case .protocol(let wrapped): return wrapped
        }
    }

    /// Initializes a `DeclGroup` instance from a `DeclGroupSyntax`.
    ///
    /// - Parameter syntax: The syntax node representing the declaration group.
    /// - Note: This initializer will fatalError if the syntax node does not match any known declaration group type.
    public init(_ syntax: DeclGroupSyntax) {
        if let syntax = syntax.as(ActorDeclSyntax.self) {
            self = .actor(Actor(syntax))
        } else if let syntax = syntax.as(ClassDeclSyntax.self) {
            self = .class(Class(syntax))
        } else if let syntax = syntax.as(EnumDeclSyntax.self) {
            self = .enum(Enum(syntax))
        } else if let syntax = syntax.as(ExtensionDeclSyntax.self) {
            self = .extension(Extension(syntax))
        } else if let syntax = syntax.as(StructDeclSyntax.self) {
            self = .struct(Struct(syntax))
        } else if let syntax = syntax.as(ProtocolDeclSyntax.self) {
            self = .protocol(Protocol(syntax))
        } else {
            fatalError("Unhandled decl group type '\(type(of: syntax))'")
        }
    }

    /// The identifier of the declaration group.
    public var identifier: String { wrapped.identifier }

    /// All members declared within the declaration group.
    public var members: [Decl] { wrapped.members }

    /// All properties declared within the declaration group.
    public var properties: [Property] { wrapped.properties }

    /// All types that the declaration group inherits from or conforms to.
    public var inheritedTypes: [Type] { wrapped.inheritedTypes }
}
