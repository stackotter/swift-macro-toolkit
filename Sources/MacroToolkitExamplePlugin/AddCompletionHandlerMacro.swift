import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/AddCompletionHandlerMacro.swift
public struct AddCompletionHandlerMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let function = Function(declaration) else {
            throw MacroError("@AddCompletionHandler only works on functions")
        }

        guard function.isAsync else {
            let newSignature = function._syntax.withAsyncModifier().signature
            let diagnostic = DiagnosticBuilder(for: function._syntax.funcKeyword)
                .message("can only add a completion-handler variant to an 'async' function")
                .messageID(domain: "AddCompletionHandlerMacro", id: "MissingAsync")
                .suggestReplacement(
                    "add 'async'",
                    old: function._syntax.signature,
                    new: newSignature
                )
                .build()

            context.diagnose(diagnostic)
            return []
        }

        let completionHandlerParameter =
            FunctionParameter(
                name: "completionHandler",
                type: "@escaping (\(raw: function.returnType?.description ?? "")) -> Void"
            )

        let callArguments = function.parameters.asPassthroughArguments

        let newFunc =
            function._syntax
            .withAsyncModifier(false)
            .withReturnType(nil)
            .withParameters(function.parameters + [completionHandlerParameter])
            .withBody([
                """
                Task {
                    completionHandler(
                        await \(raw: function.identifier)(\(raw: callArguments.joined(separator: ", ")))
                    )
                }
                """
            ])
            .withAttributes(function.attributes.removing(node))
            .withLeadingBlankLine()

        return [DeclSyntax(newFunc)]
    }
}
