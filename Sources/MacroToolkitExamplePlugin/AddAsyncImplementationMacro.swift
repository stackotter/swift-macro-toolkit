import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

public enum AddAsyncImplementationMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let decl = try AddAsyncImplementationCore.expansion(of: node, providingFunctionOf: declaration)
        return [decl]
    }
}
