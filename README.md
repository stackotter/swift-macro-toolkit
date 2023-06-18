# Swift Macro Toolkit

## Overview

Did you know that `-0xF_ep-0_2` is a valid floating point literal in Swift? Well you probably didn't
(it's equal to -63.5), and as a macro author you shouldn't even have to care! Macro Toolkit shields
you from edge cases so that users can use your macros in whatever weird (but correct) manners they
may desire.

You don't need in-depth knowledge of Swift's syntax to make a robust macro, you just need an idea.

## Supporting Swift Macro Toolkit

If you find Swift Macro Toolkit useful, please consider supporting me by
[becoming a sponsor](https://github.com/sponsors/stackotter). I spend most of my spare time
working on open-source projects, and each sponsorship helps me focus more time on making
high quality tools and libraries for the community. 

## Why use it?

See for yourself;

### Get the value of a float literal

Does `-0xF_ep-0_2` look like the type of floating point literal you want to implement parsing for?
Nope; but you don't have to.

#### With Macro Toolkit

```swift
return literal.value
```

<details>
  <summary>Without Macro Toolkit (worth a look)</summary>

  ```swift
  let string = _syntax.floatingDigits.text

  let isHexadecimal: Bool
  let stringWithoutPrefix: String
  switch string.prefix(2) {
      case "0x":
          isHexadecimal = true
          stringWithoutPrefix = String(string.dropFirst(2))
      default:
          isHexadecimal = false
          stringWithoutPrefix = string
  }

  let exponentSeparator: Character = isHexadecimal ? "p" : "e"
  let parts = stringWithoutPrefix.lowercased().split(separator: exponentSeparator)
  guard parts.count <= 2 else {
      fatalError("Float literal cannot contain more than one exponent separator")
  }

  let exponentValue: Int
  if parts.count == 2 {
      // The exponent part is always decimal
      let exponentPart = parts[1]
      let exponentPartWithoutUnderscores = exponentPart.replacingOccurrences(of: "_", with: "")
      guard
          exponentPart.first != "_",
          !exponentPart.starts(with: "-_"),
          let exponent = Int(exponentPartWithoutUnderscores)
      else {
          fatalError("Float literal has invalid exponent part: \(string)")
      }
      exponentValue = exponent
  } else {
      exponentValue = 0
  }

  let partsBeforeExponent = parts[0].split(separator: ".")
  guard partsBeforeExponent.count <= 2 else {
      fatalError("Float literal cannot contain more than one decimal point: \(string)")
  }

  // The integer part can contain underscores anywhere except for the first character (which must be a digit).
  let radix = isHexadecimal ? 16 : 10
  let integerPart = partsBeforeExponent[0]
  let integerPartWithoutUnderscores = integerPart.replacingOccurrences(of: "_", with: "")
  guard
      integerPart.first != "_",
      let integerPartValue = Int(integerPartWithoutUnderscores, radix: radix).map(Double.init)
  else {
      fatalError("Float literal has invalid integer part: \(string)")
  }

  let fractionalPartValue: Double
  if partsBeforeExponent.count == 2 {
      // The fractional part can contain underscores anywhere except for the first character (which must be a digit).
      let fractionalPart = partsBeforeExponent[1]
      let fractionalPartWithoutUnderscores = fractionalPart.replacingOccurrences(of: "_", with: "")
      guard
          fractionalPart.first != "_",
          let fractionalPartDigitsValue = Int(fractionalPartWithoutUnderscores, radix: radix)
      else {
          fatalError("Float literal has invalid fractional part: \(string)")
      }

      fractionalPartValue = Double(fractionalPartDigitsValue) / pow(Double(radix), Double(fractionalPart.count - 1))
  } else {
      fractionalPartValue = 0
  }

  let base: Double = isHexadecimal ? 2 : 10
  let multiplier = pow(base, Double(exponentValue))
  let sign: Double = _negationSyntax == nil ? 1 : -1

  return (integerPartValue + fractionalPartValue) * multiplier * sign
  ```
</details>

### Type destructuring

#### With Macro Toolkit

```swift
guard
    case let .nominal("Result", (successType, failureType))? = destructure(Type(returnType))
else {
    throw MacroError("Invalid return type")
}
```

#### Without Macro Toolkit

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

### Type normalization

Swift has many different ways to express a single type. To name a few such cases; `() == Void`,
`Int? == Optional<Int>`, and `[Int] == Array<Int>`. Swift Macro Toolkit strives to hide these details
from you, so you don't have to handle all the edge cases.

#### With Macro Toolkit

```swift
function.returnsVoid
```

#### Without Macro Toolkit

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

### Get the value of a string literal

Getting the value of a string literal (without interpolations) can be incredibly
tedious if you want to do it the right way. You have to evaluate all escape sequences
yourself (unicode ones are particularly annoying e.g. `\u{2020}`). And then if a user
wants to use a raw string literal (e.g. `#"This isn't a newline \n"#`), things get even
more difficult to get right. Don't fear though, Swift Macro Toolkit has you covered.

#### With Macro Toolkit

```swift
return literal.value
```

<details>
  <summary>Without Macro Toolkit</summary

  ```swift
  let segments = _syntax.segments.compactMap { (segment) -> String? in
      guard case let .stringSegment(segment) = segment else {
          return nil
      }
      return segment.content.text
  }
  guard segments.count == _syntax.segments.count else {
      return nil
  }

  let map: [Character: Character] = [
      "\\": "\\",
      "n": "\n",
      "r": "\r",
      "t": "\t",
      "0": "\0",
      "\"": "\"",
      "'": "'"
  ]
  let hexadecimalCharacters = "0123456789abcdefABCDEF"

  // The length of the `\###...` sequence that starts an escape sequence (zero hashes if not a raw string)
  let escapeSequenceDelimiterLength = (_syntax.openDelimiter?.text.count ?? 0) + 1
  // Evaluate backslash escape sequences within each segment before joining them together
  let transformedSegments = segments.map { segment in
      var characters: [Character] = []
      var inEscapeSequence = false
      var iterator = segment.makeIterator()
      var escapeSequenceDelimiterPosition = 0 // Tracks the current position in the delimiter if parsing one
      while let c = iterator.next() {
          if inEscapeSequence {
              if let replacement = map[c] {
                  characters.append(replacement)
              } else if c == "u" {
                  var count = 0
                  var digits: [Character] = []
                  var iteratorCopy = iterator

                  guard iterator.next() == "{" else {
                      fatalError("Expected '{' in unicode scalar escape sequence")
                  }

                  var foundClosingBrace = false
                  while let c = iterator.next() {
                      if c == "}" {
                          foundClosingBrace = true
                          break
                      }

                      guard hexadecimalCharacters.contains(c) else {
                          iterator = iteratorCopy
                          break
                      }
                      iteratorCopy = iterator

                      digits.append(c)
                      count += 1
                  }

                  guard foundClosingBrace else {
                      fatalError("Expected '}' in unicode scalar escape sequence")
                  }

                  if !(1...8).contains(count) {
                      fatalError("Invalid unicode character escape sequence (must be 1 to 8 digits)")
                  }

                  guard
                      let value = UInt32(digits.map(String.init).joined(separator: ""), radix: 16),
                      let scalar = Unicode.Scalar(value)
                  else {
                      fatalError("Invalid unicode scalar hexadecimal value literal")
                  }

                  characters.append(Character(scalar))
              }
              inEscapeSequence = false
          } else if c == "\\" && escapeSequenceDelimiterPosition == 0 {
              escapeSequenceDelimiterPosition += 1
          } else if !inEscapeSequence && c == "#" && escapeSequenceDelimiterPosition != 0 {
              escapeSequenceDelimiterPosition += 1
          } else {
              if escapeSequenceDelimiterPosition != 0 {
                  characters.append("\\")
                  for _ in 0..<(escapeSequenceDelimiterPosition - 1) {
                      characters.append("#")
                  }
                  escapeSequenceDelimiterPosition = 0
              }
              characters.append(c)
          }
          if escapeSequenceDelimiterPosition == escapeSequenceDelimiterLength {
              inEscapeSequence = true
              escapeSequenceDelimiterPosition = 0
          }
      }
      return characters.map(String.init).joined(separator: "")
  }

  return transformedSegments.joined(separator: "")
  ```
</details>

### Diagnostic creation

#### With Macro Toolkit

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

#### Without Macro Toolkit

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
