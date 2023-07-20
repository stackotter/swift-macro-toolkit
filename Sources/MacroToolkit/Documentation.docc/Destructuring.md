# Destructuring

Destructuring is a game changer for developing robust macros without drowning yourself in verbose input validation code.

## Overview

Destructuring is a common concept in programming available in many languages from Javascript to Rust. It is the act of
taking data and pulling it apart into its component parts; often with some pattern matching involved.

## A first look

The quickest way to demonstrate why you'll love destructuring is to compare a snippet that uses MacroKit and destructuring,
to one that doesn't.

Notice how when we're using MacroToolkit, we simply describe what we expect the `returnType` to look like, and MacroToolkit
performs all of the pattern matching and validation for us!

### Without MacroToolkit

```swift
// We're expecting the return type to look like `Result<A, B>`
guard
    let simpleReturnType = returnType.as(SimpleTypeIdentifierSyntax.self),
    simpleReturnType.name.description == "Result",
    let genericArguments = (simpleReturnType.genericArgumentClause?.arguments).map(Array.init),
    genericArguments.count == 2
else {
    throw MacroError("Invalid return type")
}
let successType = genericArguments[0]
let failureType = genericArguments[1]
```

### With MacroToolkit

```swift
// We're expecting the return type to look like `Result<A, B>`
guard case let .simple("Result", (successType, failureType))? = destructure(returnType) else {
    throw MacroError("Invalid return type")
}
```

## General destructuring

MacroToolkit provides a set of functions that can be used to destructure any array-like data (e.g. argument lists,
attribute lists, etc.). Lets use destructuring to parse an argument list.

```swift
// We're expecting exactly two arguments; a name and an age
guard
    let ((nil, nameExpr), (nil, ageExpr)) = destructure(attribute.arguments),
    let name = nameExpr.asStringLiteral?.value,
    let age = ageExpr.asIntegerLiteral?.value
else {
    throw MacroError("Usage: @MyMacro(\"stackotter\", 105)")
}
```

- 0 elements: ``destructure(_:)-12e8l``
- 1 element: ``destructureSingle(_:)-1dg2k``
- 2 elements: ``destructure(_:)-2c4y9``
- 3 elements: ``destructure(_:)-65tob``
- 4 elements: ``destructure(_:)-2vkcn``
- 5 elements: ``destructure(_:)-2ooj8``
- 6 elements: ``destructure(_:)-ztug``

At the moment a separate implementation is required for each number of arguments because variadic generics aren't
yet ready for this use-case. In the future the 6 element limit will be lifted (and if you need it lifted now you
can just ask and I can bump up the maximum with a bit of copy and pasting).

## Type destructuring

As you saw in [A first look](#A-first-look), type destructuring is a highly expressive way to parse and validate
types.

### Destructuring arbitrary types

So far only the ``Type/simple(_:)`` and ``Type/function(_:)`` variants of ``Type`` can be destructured. But with minimal
effort this can be expanded to variants such as ``Type/tuple(_:)``.

```swift
// We're expecting the function to have a signature of the form `(parameterType1, parameterType2) -> returnType`.
guard
    case .function((parameterType1, parameterType2), returnType) = destructure(functionType)
else {
    throw MacroError("Invalid return type")
}
```

- 0 unknowns: ``destructure(_:)-6saio``
- 1 unknown: ``destructureSingle(_:)-9tjyg``
- 2 unknowns: ``destructure(_:)-1vwqf``
- 3 unknowns: ``destructure(_:)-365tz``
- 4 unknowns: ``destructure(_:)-867ko``
- 5 unknowns: ``destructure(_:)-5joxh``
- 6 unknowns: ``destructure(_:)-nbe1``

### Destructuring simple types (aka nominal types)

Simple types can be destructured into a name and a collection of generic type parameters.

```swift
// We're expecting the return type to look like `Result<A, B>`.
guard case let ("Result", (successType, failureType))? = destructure(simpleReturnType) else {
    throw MacroError("Invalid return type")
}
```

- 0 generic type parameters: ``destructure(_:)-3e860``
- 1 generic type parameter: ``destructureSingle(_:)-chrb``
- 2 generic type parameters: ``destructure(_:)-3xse5``
- 3 generic type parameters: ``destructure(_:)-8aio2``
- 4 generic type parameters: ``destructure(_:)-560mv``
- 5 generic type parameters: ``destructure(_:)-1h0o8``
- 6 generic type parameters: ``destructure(_:)-45hpd``

### Destructuring function types

Function types can be destructured into a collection of parameter types and a return type.

```swift
// We're expecting the function to have a signature of the form `(first, _, third) -> Int`.
guard
    // Destructure a function type
    case let ((first, _, third), returnType)? = destructure(functionType),
    // Destructure an arbitrary type
    case .simple("Int", ()) = destructure(returnType)
else {
    throw MacroError("Invalid return type")
}
```

- 0 parameter types: ``destructure(_:)-180j9``
- 1 parameter type: ``destructureSingle(_:)-5r8sv``
- 2 parameter types: ``destructure(_:)-2idom``
- 3 parameter types: ``destructure(_:)-8g4v5``
- 4 parameter types: ``destructure(_:)-7o2hx``
- 5 parameter types: ``destructure(_:)-8m59b``
- 6 parameter types: ``destructure(_:)-9wc1b``
