import SwiftSyntax

/// Wraps an attribute (e.g. `public` or `@dynamicMemberLookup`).
public struct Attribute {
    /// The attribute's underlying syntax.
    public var _syntax: AttributeSyntax

    /// Wraps an attribute's syntax.
    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    /// Creates a new attribute with the given name.
    public init(named name: String) {
        _syntax = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(
                name: .identifier(name)
            )
        )
    }

    /// The attribute's name.
    public var name: SimpleType {
        guard let type = SimpleType(_syntax.attributeName) else {
            fatalError(
                "Assumed that attribute name would be simple type, but got: \(_syntax.attributeName)"
            )
        }
        return type
    }

    /// Attempts to get the attribute as a macro attribute (e.g. `@MyMacro` as opposed to `@propertyWrapper`).
    public var asMacroAttribute: MacroAttribute? {
        MacroAttribute(_syntax)
    }
}
