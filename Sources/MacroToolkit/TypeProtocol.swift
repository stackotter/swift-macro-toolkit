import SwiftSyntax

/// A protocol for type syntax wrappers to conform to. Allows simple conversion between type wrappers.
public protocol TypeProtocol {
    /// The underlying type syntax being wrapped.
    associatedtype WrappedSyntax: TypeSyntaxProtocol
    /// The syntax associated with the type itself. For diagnostics ``_syntax``
    /// may be better (as it includes the syntax for associated attributes).
    var _baseSyntax: WrappedSyntax { get }
    /// The syntax associated with the attributes attached to the type (if any).
    /// (e.g. the type `@escaping () -> ()` has the `@escaping` attribute).
    var _attributedSyntax: AttributedTypeSyntax? { get }
    /// This initializer is an implementation detail and shouldn't need to be
    /// used for most normal usecases.
    init(_ syntax: WrappedSyntax, attributedSyntax: AttributedTypeSyntax?)
}

extension TypeProtocol {
    /// The syntax node referring to the entire type (including attributes if any).
    /// Use for diagnostics.
    public var _syntax: any TypeSyntaxProtocol {
        _attributedSyntax ?? _baseSyntax
    }

    /// A textual representation of the type without trivia (not normalized).
    public var description: String {
        _syntax.withoutTrivia().description
    }

    /// Attempts to convert wrapped type syntax to this specific type of type syntax
    /// (how confusing).
    public init?(_ type: Type) {
        guard let type = Self(type._syntax) else {
            return nil
        }
        self = type
    }

    /// Initializes this type of type syntax from attributed syntax (the attributed
    /// syntax's inner type syntax is passed to the regular `init` and the attributes
    /// are stored in `_attributedTypeSyntax`).
    public init?(attributedSyntax: AttributedTypeSyntax) {
        guard let baseSyntax = attributedSyntax.baseType.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(baseSyntax, attributedSyntax: attributedSyntax)
    }

    /// Attempts to initialize this type of type syntax from arbitrary type syntax.
    public init?(_ syntax: any TypeSyntaxProtocol) {
        if let syntax = syntax.as(WrappedSyntax.self) {
            self.init(syntax, attributedSyntax: nil)
        } else if let attributedSyntax = syntax.as(AttributedTypeSyntax.self) {
            self.init(attributedSyntax: attributedSyntax)
        } else {
            return nil
        }
    }
}
