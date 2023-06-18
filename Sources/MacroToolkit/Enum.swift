import SwiftSyntax

/// Wraps an enum declaration.
public struct Enum {
    public var _syntax: EnumDeclSyntax
    
    public init?(_ syntax: any DeclGroupSyntax) {
        guard let syntax = syntax.as(EnumDeclSyntax.self) else {
            return nil
        }
        _syntax = syntax
    }

    public init(_ syntax: EnumDeclSyntax) {
        _syntax = syntax
    }

    public var identifier: String {
        _syntax.identifier.withoutTrivia().text
    }

    public var cases: [EnumCase] {
        _syntax.memberBlock.members
            .compactMap { member in
                member.decl.as(EnumCaseDeclSyntax.self)
            }
            .flatMap { syntax in
                syntax.elements.map(EnumCase.init)
            }
    }

    public var isPublic: Bool {
        _syntax.isPublic
    }
}
