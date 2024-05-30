import SwiftSyntax

/// A protocol for modifiers in Swift that are represented by `TokenKind`.
public protocol ModifierProtocol: RawRepresentable where RawValue == TokenKind {
    /// Initializes a `Modifier` from a list of declaration modifiers.
    ///
    /// - Parameter modifiers: A list of declaration modifiers.
    init?(firstModifierOfKindIn: DeclModifierListSyntax)
}

extension ModifierProtocol {
    /// Default implementation for initializing a `Modifier` from a list of declaration modifiers.
    ///
    /// - Parameter modifiers: A list of declaration modifiers.
    public init?(firstModifierOfKindIn: DeclModifierListSyntax) {
        for element in firstModifierOfKindIn {
            guard let modifier = Self(rawValue: element.name.tokenKind) else { continue }
            self = modifier
            return
        }
        return nil
    }
}
