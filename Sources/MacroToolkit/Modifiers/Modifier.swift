import SwiftSyntax

/// A protocol for modifiers in Swift that are represented by `TokenKind`.
public protocol Modifier: RawRepresentable where RawValue == TokenKind {
    /// Initializes a `Modifier` from a list of declaration modifiers.
    ///
    /// - Parameter modifiers: A list of declaration modifiers.
    init?(modifiers: DeclModifierListSyntax)
}

extension Modifier {
    /// Default implementation for initializing a `Modifier` from a list of declaration modifiers.
    ///
    /// - Parameter modifiers: A list of declaration modifiers.
    public init?(modifiers: DeclModifierListSyntax) {
        for element in modifiers {
            guard let modifier = Self(rawValue: element.name.tokenKind) else { continue }
            self = modifier
            return
        }
        return nil
    }
}
