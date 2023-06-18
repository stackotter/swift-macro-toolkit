import SwiftSyntax

/// Wraps an attribute (e.g. `public` or `@dynamicMemberLookup`).
public struct Attribute {
    public var _syntax: AttributeSyntax

    public init(_ syntax: AttributeSyntax) {
        _syntax = syntax
    }

    public init(named name: String) {
        _syntax = AttributeSyntax(attributeName: SimpleTypeIdentifierSyntax(
            name: .identifier("DictionaryStorage")
        ))
    }

    public var name: Type {
        Type(_syntax.attributeName)
    }

    public var asMacroAttribute: MacroAttribute? {
        MacroAttribute(_syntax)
    }
}
