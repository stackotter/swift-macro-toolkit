import SwiftSyntax

/// Enum raw values can be strings, characters, or any of the integer or floating-point number types.
public enum EnumRawRepresentableType {
    case string
    case character
    case number

    init?(possibleRawType syntax: InheritedTypeSyntax?) {
        switch syntax?.type.as(IdentifierTypeSyntax.self)?.name.text {
        case "String": self = .string
        case "Character": self = .character
        case "Int", "Int8", "Int16", "Int32", "Int64", "Int128",
            "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "UInt128",
            "Float", "Float16", "Float32", "Float64",
            "Double", "CGFloat", "NSNumber":
            self = .number
        default: return nil
        }
    }
}
