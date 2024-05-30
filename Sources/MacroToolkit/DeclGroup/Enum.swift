import SwiftSyntax

/// Wraps an `enum` declaration.
public struct Enum: DeclGroupProtocol, RepresentableBySyntax {
    /// The underlying syntax node for the `enum` declaration.
    public var _syntax: EnumDeclSyntax

    /// The identifier (name) of the `enum`.
    public var identifier: String {
        _syntax.name.withoutTrivia().text
    }

    /// Initializes an `Enum` instance with the given syntax node.
    ///
    /// - Parameter syntax: The syntax node representing the `enum` declaration.
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
