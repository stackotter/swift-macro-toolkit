import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public enum AddAsyncAllMembersMacro: MemberMacro {
    // We defer to the old method signature so that we can support older swift-syntax
    // versions.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try expansion(of: node, providingMembersOf: declaration, in: context)
    }

    public static func expansion(
        of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        declaration.memberBlock.members.map(\.decl).compactMap {
            try? AddAsyncMacroCore.expansion(of: nil, providingFunctionOf: $0)
        }
    }
}
