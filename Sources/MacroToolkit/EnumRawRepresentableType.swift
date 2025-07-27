import SwiftSyntax

/// Enum raw values can be strings, characters, or any of the integer or floating-point number types.
public enum EnumRawRepresentableType {
    case string(syntax: IdentifierTypeSyntax)
    case character(syntax: IdentifierTypeSyntax)
    case integer(syntax: IdentifierTypeSyntax)
    case float(syntax: IdentifierTypeSyntax)

    init?(possibleRawType syntax: InheritedTypeSyntax?) {
        guard let type = syntax?.type.as(IdentifierTypeSyntax.self) else { return nil }
        switch type.name.text {
            case "String", "NSString":
                self = .string(syntax: type)
            case "Character":
                self = .character(syntax: type)
            case "Int", "Int8", "Int16", "Int32", "Int64", "Int128",
                 "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "UInt128":
                self = .integer(syntax: type)
            case "Float", "Float16", "Float32", "Float64",
                 "Double", "CGFloat", "NSNumber":
                self = .float(syntax: type)
            default: return nil
        }
    }
}
