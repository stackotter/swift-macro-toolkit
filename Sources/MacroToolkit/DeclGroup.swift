import SwiftSyntax

// TODO: Enable initializing from an `any DeclGroupSyntax`.
/// Wraps a declaration group (a declaration with a scoped block of members).
/// For example an `enum` or a `struct` etc.
public struct DeclGroup<WrappedSyntax: DeclGroupSyntax>: DeclGroupProtocol {
    public var _syntax: WrappedSyntax

    public init(_ syntax: WrappedSyntax) {
        _syntax = syntax
    }

    public var identifier: String {
        if let `struct` = asStruct {
            `struct`.identifier
        } else if let `enum` = asEnum {
            `enum`.identifier
        } else {
            // TODO: Implement wrappers for all other decl group types.
            fatalError("Unhandled decl group type '\(type(of: _syntax))'")
        }
    }

    /// Gets the decl group as a struct if it's a struct.
    public var asStruct: Struct? {
        Struct(_syntax)
    }

    /// Gets the decl group as an enum if it's an enum.
    public var asEnum: Enum? {
        Enum(_syntax)
    }
}
