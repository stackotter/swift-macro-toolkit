import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import MacroToolkit

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
        // Only on functions at the moment. We could handle initializers as well
        // with a bit of work.
        guard let function = Function(declaration) else {
            throw MacroError("@AddCompletionHandler only works on functions")
        }

        // This only makes sense for async functions.
        guard function.isAsync else {
            let newSignature = function._syntax.withAsyncModifier().signature
            let messageID = MessageID(domain: "MacroExamples", id: "MissingAsync")

            let diagnostic = Diagnostic(
                node: Syntax(function._syntax.funcKeyword),
                message: SimpleDiagnosticMessage(
                    message: "can only add a completion-handler variant to an 'async' function",
                    diagnosticID: messageID,
                    severity: .error
                ),
                fixIts: [
                    FixIt(
                        message: SimpleDiagnosticMessage(
                            message: "add 'async'",
                            diagnosticID: messageID,
                            severity: .error
                        ),
                        changes: [
                            FixIt.Change.replace(
                                oldNode: Syntax(function._syntax.signature),
                                newNode: Syntax(newSignature)
                            )
                        ]
                    )
                ]
            )

            context.diagnose(diagnostic)
            return []
        }

        // Form the completion handler parameter.
        let resultType: Type? = function.returnType

        let completionHandlerParameter =
            FunctionParameterSyntax(
                firstName: .identifier("completionHandler"),
                colon: .colonToken(trailingTrivia: .space),
                type: "@escaping (\(raw: resultType?.description ?? "")) -> Void" as TypeSyntax
            )

        // Add the completion handler parameter to the parameter list.
        let newParameters = function.parameters + [FunctionParameter(completionHandlerParameter)]

        let callArguments = function.parameters.map { parameter in
            if let label = parameter.label {
                return "\(label): \(parameter.name)"
            }

            return "\(parameter.name)"
        }

        let call: ExprSyntax =
            "\(raw: function.identifier)(\(raw: callArguments.joined(separator: ", ")))"

        let newBody: ExprSyntax =
            """
            Task {
                completionHandler(await \(call))
            }
            """

        let newAttributes = function.attributes.removing(node)

        let newFunc =
            function._syntax
            .withAsyncModifier(false)
            .withReturnType(nil)
            .withParameters(newParameters)
            .withBody([newBody])
            .withAttributes(newAttributes)
            .withLeadingBlankLine()

        return [DeclSyntax(newFunc)]
    }
}
