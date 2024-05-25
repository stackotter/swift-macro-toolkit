import SwiftSyntax

/// Represents context-specific modifiers for declarations (e.g., static, class).
public enum DeclarationContextModifier: RawRepresentable, ModifierProtocol {
    case `static`
    case `class`

    /// Initializes a `DeclarationContextModifier` from a `TokenKind`.
    ///
    /// - Parameter rawValue: The `TokenKind` representing a context-specific keyword.
    public init?(rawValue: TokenKind) {
        switch rawValue {
            case .keyword(.static):
                self = .static
            case .keyword(.class):
                self = .class
            default:
                return nil
        }
    }

    /// The `TokenKind` corresponding to the `DeclarationContextModifier`.
    public var rawValue: TokenKind {
        switch self {
            case .static:
                return .keyword(.static)
            case .class:
                return .keyword(.class)
        }
    }
}
