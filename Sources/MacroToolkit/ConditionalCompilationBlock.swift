import SwiftSyntax

/// A compile-time conditional block (i.e. `#if ...`).
public struct ConditionalCompilationBlock {
    public var _syntax: IfConfigDeclSyntax

    public init(_ syntax: IfConfigDeclSyntax) {
        _syntax = syntax
    }
}
