import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

public enum AddAsyncInterfaceAllMembersMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw MacroError("Macro `AddAsyncInterfaceToAllMemberMacro` can only be applied to a protocol")
        }

        let methods = protocolDecl.memberBlock.members.map(\.decl).compactMap {
            try? AddAsyncInterfaceCore.expansion(of: nil, providingFunctionOf: $0)
        }
        return methods
    }
}
