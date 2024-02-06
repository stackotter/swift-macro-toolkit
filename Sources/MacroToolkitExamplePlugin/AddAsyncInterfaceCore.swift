import SwiftSyntax
import MacroToolkit
import SwiftSyntaxMacros

enum AddAsyncInterfaceCore {
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

        // TODO: Make better codeblock init
        let newFunc =
            function._syntax
                .withParameters(newParameters)
                .withReturnType(successReturnType)
                .withAsyncModifier()
                .withThrowsModifier(isResultReturn)
                .withAttributes(filteredAttributes)
                .withLeadingBlankLine()

        return DeclSyntax(newFunc)
    }
}
