import SwiftSyntax

/// A compile-time conditional block (i.e. `#if ... \n ... \n #endif`).
public struct ConditionalCompilationBlock {
    /// The underlying syntax node.
    public var _syntax: IfConfigDeclSyntax

    /// Wraps a compile-time conditional block syntax node.
    public init(_ syntax: IfConfigDeclSyntax) {
        _syntax = syntax
    }
}
