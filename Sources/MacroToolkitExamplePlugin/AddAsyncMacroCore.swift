import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/AddAsyncMacro.swift

enum AddAsyncMacroCore {
    static func expansion(of node: AttributeSyntax?, providingFunctionOf declaration: some DeclSyntaxProtocol) throws -> DeclSyntax {
        // Only on functions at the moment.
        guard let function = Function(declaration) else {
            throw MacroError("@AddAsync only works on functions")
        }

        // This only makes sense for non async functions.
        guard !function.isAsync else {
            throw MacroError("@AddAsync requires a non async function")
        }

        // This only makes sense void functions
        guard function.returnsVoid else {
            throw MacroError("@AddAsync requires a function that returns void")
        }

        // Requires a completion handler block as last parameter
        guard
            let completionHandlerType = function.parameters.last?.type.asFunctionType
        else {
            throw MacroError(
                "@AddAsync requires a function that has a completion handler as last parameter")
        }

        // Completion handler needs to return Void
        guard completionHandlerType.returnType.isVoid else {
            throw MacroError(
                "@AddAsync requires a function that has a completion handler that returns Void")
        }

        guard let returnType = completionHandlerType.parameters.first else {
            throw MacroError(
                "@AddAsync requires a function that has a completion handler that has one parameter"
            )
        }

        // Destructure return type
        let successReturnType: Type
        let isResultReturn: Bool
        if case let .simple("Result", (successType, _)) = destructure(returnType) {
            isResultReturn = true
            successReturnType = successType
        } else {
            isResultReturn = false
            successReturnType = returnType
        }

        // Remove completionHandler and comma from the previous parameter
        let newParameters = function.parameters.dropLast()

        // Drop the @AddAsync attribute from the new declaration.
        var filteredAttributes = function.attributes
        if let node {
            filteredAttributes = filteredAttributes.removing(node)
        }

        let callArguments = newParameters.asPassthroughArguments

        let newBody = function._syntax.body.map { _ in
            let switchBody: ExprSyntax =
            """
            switch returnValue {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
            }
            """
            
            let continuationExpr =
            isResultReturn
            ? "try await withCheckedThrowingContinuation { continuation in"
            : "await withCheckedContinuation { continuation in"
            
            let newBody: ExprSyntax =
            """
            \(raw: continuationExpr)
                \(raw: function.identifier)(\(raw: callArguments.joined(separator: ", "))) { returnValue in
                    \(isResultReturn ? switchBody : "continuation.resume(returning: returnValue)")
                }
            }
            """
            return CodeBlockSyntax([newBody])
        }
        // TODO: Make better codeblock init
        var newFunc =
            function._syntax
            .withParameters(newParameters)
            .withReturnType(successReturnType)
            .withAsyncModifier()
            .withThrowsModifier(isResultReturn)
            .withAttributes(filteredAttributes)
            .withLeadingBlankLine()

        if let newBody {
            newFunc = newFunc.withBody(newBody)
        }

        return DeclSyntax(newFunc)
    }
}
