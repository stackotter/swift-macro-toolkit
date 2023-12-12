import SwiftSyntax

/// Wraps an `enum` declaration.
public struct Enum: DeclGroupProtocol {
    public var _syntax: EnumDeclSyntax

    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    public init(_ syntax: EnumDeclSyntax) {
        _syntax = syntax
    }

    /// The `enum`'s cases.
    public var cases: [EnumCase] {
        _syntax.memberBlock.members
            .compactMap { member in
                member.decl.as(EnumCaseDeclSyntax.self)
            }
            .flatMap { syntax in
                syntax.elements.map(EnumCase.init)
            }
    }
}
