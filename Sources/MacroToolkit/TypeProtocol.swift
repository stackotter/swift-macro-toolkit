import SwiftSyntax

public protocol TypeProtocol {
    associatedtype WrappedSyntax: TypeSyntaxProtocol
    var _baseSyntax: WrappedSyntax { get }
    var _attributedSyntax: AttributedTypeSyntax? { get }
    init(_ syntax: WrappedSyntax, attributedSyntax: AttributedTypeSyntax?)
}

extension TypeProtocol {
    public var _syntax: any TypeSyntaxProtocol {
        _attributedSyntax ?? _baseSyntax
    }

    public var description: String {
        _syntax.withoutTrivia().description
    }

    public init?(_ type: Type) {
        guard let type = Self(type._syntax) else {
            return nil
        }
        self = type
    }

    public init?(attributedSyntax: AttributedTypeSyntax) {
        guard let baseSyntax = attributedSyntax.baseType.as(WrappedSyntax.self) else {
            return nil
        }
        self.init(baseSyntax, attributedSyntax: attributedSyntax)
    }

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
