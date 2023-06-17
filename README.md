# Swift Macro Toolkit

## Overview

A toolkit consisting of wrappers and extensions for working with Swift Syntax; with a focus
on normalization and expressiveness.

## Supporting Swift Macro Toolkit

If you find Swift Macro Toolkit useful, please consider supporting me by
[becoming a sponsor](https://github.com/sponsors/stackotter). I spend most of my spare time
working on open-source projects, and each sponsorship helps me focus more time on making
high quality tools and libraries for the community. 

## Why use it?

See for yourself;

### Type normalization

Swift has many different ways to express a single type. To name a few such cases; `() == Void`,
`Int? == Optional<Int>`, and `[Int] == Array<Int>`. Swift Macro Toolkit strives to hide these details
from you, so you don't have to handle all the edge cases.

#### Before

```swift
func returnsVoid(_ function: FunctionDeclSyntax) -> Bool {
    // Function can either have no return type annotation, `()`, `Void`, or a nested single
    // element tuple with a Void-like inner type (e.g. `((((()))))` or `(((((Void)))))`)
    func isVoid(_ type: TypeSyntax) -> Bool {
        if type.description == "Void" || type.description == "()" {
            return true
        }

        guard let tuple = type.as(TupleTypeSyntax.self) else {
            return false
        }

        if let element = tuple.elements.first, tuple.elements.count == 1 {
            let isLabeled = element.name == nil && element.secondName == nil
            return isLabeled && isVoid(TypeSyntax(element.type))
        }
        return false
    }

    guard let returnType = function.output?.returnType else {
        return false
    }
    return isVoid(returnType)
}
```

#### After

```swift
function.returnsVoid
```

### Type destructuring

#### Before

```swift
guard
    let nominalReturnType = returnType.as(SimpleTypeIdentifierSyntax.self),
    nominalReturnType.name.description == "Result",
    let genericArguments = (nominalReturnType.genericArgumentClause?.arguments).map(Array.init),
    genericArguments.count == 2
else {
    throw MacroError("Invalid return type")
}
let successType = genericArguments[0]
let failureType = genericArguments[1]
```

#### After

```swift
guard
    case let .nominal("Result", (successType, failureType))? = destructure(Type(returnType))
else {
    throw MacroError("Invalid return type")
}
```

### Diagnostic creation

#### Before

```swift
let diagnostic = Diagnostic(
    node: Syntax(funcDecl.funcKeyword),
    message: SimpleDiagnosticMessage(
        message: "can only add a completion-handler variant to an 'async' function",
        diagnosticID: MessageID(domain: "AddCompletionHandlerMacro", id: "MissingAsync"),
        severity: .error
    ),
    fixIts: [
        FixIt(
            message: SimpleDiagnosticMessage(
                message: "add 'async'",
                diagnosticID: MessageID(domain: "AddCompletionHandlerMacro", id: "MissingAsync"),
                severity: .error
            ),
            changes: [
                FixIt.Change.replace(
                    oldNode: Syntax(funcDecl.signature),
                    newNode: Syntax(newSignature)
                )
            ]
        ),
    ]
)
```

#### After

```swift
let diagnostic = DiagnosticBuilder(for: function._syntax.funcKeyword)
    .message("can only add a completion-handler variant to an 'async' function")
    .messageID(domain: "AddCompletionHandlerMacro", id: "MissingAsync")
    .suggestReplacement(
        "add 'async'",
        old: function._syntax.signature,
        new: newSignature
    )
    .build()
```
