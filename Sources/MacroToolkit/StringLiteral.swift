import SwiftSyntax

/// Wraps a string literal (e.g. `"Hello, world!"`).
public struct StringLiteral: LiteralProtocol {
    public var _syntax: StringLiteralExprSyntax

    public init(_ syntax: StringLiteralExprSyntax) {
        _syntax = syntax
    }

    /// `nil` if the literal contains string interpolation.
    public var value: String? {
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
            "'": "'",
        ]
        let hexadecimalCharacters = "0123456789abcdefABCDEF"

        // TODO: Modularise this code a bit to clean it up
        // The length of the `\###...` sequence that starts an escape sequence (zero hashes if not a raw string)
        let escapeSequenceDelimiterLength = (_syntax.openingPounds?.text.count ?? 0) + 1
        // Evaluate backslash escape sequences within each segment before joining them together
        let transformedSegments = segments.map { segment in
            var characters: [Character] = []
            var inEscapeSequence = false
            var iterator = segment.makeIterator()
            var escapeSequenceDelimiterPosition = 0  // Tracks the current position in the delimiter if parsing one
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
                            fatalError(
                                "Invalid unicode character escape sequence (must be 1 to 8 digits)")
                        }

                        guard
                            let value = UInt32(
                                digits.map(String.init).joined(separator: ""), radix: 16),
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
    }

    public var containsInterpolation: Bool {
        value == nil
    }
}
