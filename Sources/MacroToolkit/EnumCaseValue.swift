import SwiftSyntax

/// The value associate with a specific enum case declaration.
public enum EnumCaseValue {
    case associatedValue([EnumCaseAssociatedValueParameter])
    case rawValue(InitializerClauseSyntax)
}
