import SwiftSyntax

public struct DeclGroup {
    public var _syntax: DeclGroupSyntax

    public init(_ syntax: DeclGroupSyntax) {
        _syntax = syntax
    }

    public var isPublic: Bool {
        _syntax.isPublic
    }

    public var members: [Decl] {
        _syntax.memberBlock.members.map(\.decl).map(Decl.init)
    }
}
