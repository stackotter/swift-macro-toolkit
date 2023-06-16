import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxMacros
import MacroToolkit

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/AddBlocker.swift
/// Implementation of the `addBlocker` macro, which demonstrates how to
/// produce detailed diagnostics from a macro implementation for an utterly
/// silly task: warning about every "add" (binary +) in the argument, with a
/// Fix-It that changes it to a "-".
public struct AddBlocker: ExpressionMacro {
    class AddVisitor: SyntaxRewriter {
        var diagnostics: [Diagnostic] = []

        override func visit(
            _ node: BinaryOperatorExprSyntax
        ) -> ExprSyntax {
            if node.operatorToken.text == "+" {
                let messageID = MessageID(domain: "ExampleMacros", id: "addBlocker")
                diagnostics.append(
                    DiagnosticBuilder(for: node.operatorToken)
                        .message("blocked an add; did you mean to subtract?")
                        .messageID(messageID)
                        .severity(.warning)
                        .suggestReplacement(
                            "use '-'",
                            old: node.operatorToken,
                            new: node.operatorToken.with(\.tokenKind, .binaryOperator("-"))
                        )
                        .build()
                )

                return ExprSyntax(
                    node.with(
                        \.operatorToken,
                        node.operatorToken.with(\.tokenKind, .binaryOperator("-"))
                    )
                )
            }

            return ExprSyntax(node)
        }
    }

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let (argument): (TupleExprElementSyntax) = destructure(node.argumentList) else {
            throw MacroError("#addBlocker only expects one argument")
        }

        let visitor = AddVisitor()
        let result = visitor.visit(argument.expression)

        for diag in visitor.diagnostics {
            context.diagnose(diag)
        }

        return ExprSyntax(result)
    }
}
