import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

public enum AddAsyncAllMembersMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        declaration.memberBlock.members.map(\.decl).compactMap {
            try? AddAsyncMacroCore.expansion(of: nil, providingFunctionOf: $0)
        }
    }
}
