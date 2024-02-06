import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

public enum AddAsyncInterfaceMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let decl = try AddAsyncInterfaceCore.expansion(of: node, providingFunctionOf: declaration)
        return [decl]
    }
}
