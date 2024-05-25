import SwiftSyntax

/// Represents access control levels in Swift (e.g., private, public).
public enum AccessModifier: RawRepresentable, ModifierProtocol, Comparable {
    case `private`
    case `fileprivate`
    case `internal`
    case `package`
    case `public`
    case `open`

    /// Initializes an `AccessModifier` from a `TokenKind`.
    ///
    /// - Parameter rawValue: The `TokenKind` representing an access control keyword.
    public init?(rawValue: TokenKind) {
        switch rawValue {
            case .keyword(.private):
                self = .private
            case .keyword(.fileprivate):
                self = .fileprivate
            case .keyword(.internal):
                self = .internal
            case .keyword(.package):
                self = .package
            case .keyword(.public):
                self = .public
            case .keyword(.open):
                self = .open
            default:
                return nil
        }
    }

    /// The `TokenKind` corresponding to the `AccessModifier`.
    public var rawValue: TokenKind {
        switch self {
            case .private:
                return .keyword(.private)
            case .fileprivate:
                return .keyword(.fileprivate)
            case .internal:
                return .keyword(.internal)
            case .package:
                return .keyword(.package)
            case .public:
                return .keyword(.public)
            case .open:
                return .keyword(.open)
        }
    }

    /// The string name of the `AccessModifier`.
    public var name: String {
        switch self {
            case .private:
                return "private"
            case .fileprivate:
                return "fileprivate"
            case .internal:
                return "internal"
            case .package:
                return "package"
            case .public:
                return "public"
            case .open:
                return "open"
        }
    }
}
