import Foundation
import SwiftSyntax

/// Wraps a regex literal (e.g. `/abc/`).
public struct RegexLiteral: LiteralProtocol {
    public var _syntax: RegexLiteralExprSyntax

    public init(_ syntax: RegexLiteralExprSyntax) {
        _syntax = syntax
    }

    /// On macOS 13.0 and up you can use ``RegexLiteral/regexValue()`` to get the parsed regex value.
    public var value: String {
        _syntax.regexPattern.text
    }

    /// Rethrows parsing errors thrown by the `Regex` initializer.
    @available(macOS 13.0, *)
    public func regexValue() throws -> Regex<AnyRegexOutput> {
        return try Regex(_syntax.regexPattern.text)
    }
}
