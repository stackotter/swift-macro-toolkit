import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/OptionSetMacro.swift

enum OptionSetMacroDiagnostic {
    case requiresStruct
    case requiresStringLiteral(String)
    case requiresOptionsEnum(String)
    case requiresOptionsEnumRawType
}

extension OptionSetMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    var message: String {
        switch self {
            case .requiresStruct:
                return "'OptionSet' macro can only be applied to a struct"

            case .requiresStringLiteral(let name):
                return "'OptionSet' macro argument \(name) must be a string literal"

            case .requiresOptionsEnum(let name):
                return "'OptionSet' macro requires nested options enum '\(name)'"

            case .requiresOptionsEnumRawType:
                return "'OptionSet' macro requires a raw type"
        }
    }

    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "OptionSet.\(self)")
    }
}

public struct OptionSetMacro {
    /// Decodes the arguments to the macro expansion.
    /// - Returns: the important arguments used by the various roles of this
    ///   macro inhabits, or nil if an error occurred.
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> (Struct, Enum, Type)? {
        let attribute = MacroAttribute(attribute)

        // Determine the name of the options enum
        let optionsEnumName: String
        if let argument = attribute.argument(labeled: "optionsName") {
            guard let stringLiteral = argument.asStringLiteral?.value else {
                context.diagnose(
                    OptionSetMacroDiagnostic
                        .requiresStringLiteral("optionsName")
                        .diagnose(at: argument._syntax)
                )
                return nil
            }

            optionsEnumName = stringLiteral
        } else {
            optionsEnumName = "Options"
        }

        // Only apply to structs
        guard let structDecl = Struct(decl) else {
            context.diagnose(OptionSetMacroDiagnostic.requiresStruct.diagnose(at: decl))
            return nil
        }

        // Find the option enum within the struct
        guard
            let optionsEnum = structDecl.members.compactMap(\.asEnum)
                .first(where: { $0.identifier == optionsEnumName })
        else {
            context.diagnose(
                OptionSetMacroDiagnostic.requiresOptionsEnum(optionsEnumName).diagnose(at: decl)
            )
            return nil
        }

        // Retrieve the raw type from the attribute
        guard case let .simple(_, (rawType)) = destructureSingle(attribute.name) else {
            context.diagnose(
                OptionSetMacroDiagnostic.requiresOptionsEnumRawType.diagnose(at: attribute._syntax))
            return nil
        }

        return (structDecl, optionsEnum, rawType)
    }
}

extension OptionSetMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        // Decode the expansion arguments. If there is an explicit conformance to
        // OptionSet already, don't add one.
        guard
            let (structDecl, _, _) = decodeExpansion(
                of: node,
                attachedTo: declaration,
                in: context
            ),
            !structDecl.inheritedTypes.contains(where: { type in
                type.description == "OptionSet"
            })
        else {
            return []
        }

        return [
            try ExtensionDeclSyntax(
                """
                extension \(type): OptionSet {}
                """
            )
        ]
    }
}

extension OptionSetMacro: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Decode the expansion arguments.
        guard
            let (structDecl, optionsEnum, rawType) = decodeExpansion(
                of: attribute,
                attachedTo: decl,
                in: context
            )
        else {
            return []
        }

        let cases = optionsEnum.cases

        // TODO: This seems wrong, surely other modifiers would also make sense to passthrough?
        let access = structDecl.isPublic ? "public " : ""

        let staticVars = cases.map { (case_) -> DeclSyntax in
            """
            \(raw: access)static let \(raw: case_.identifier): Self =
                Self(rawValue: 1 << \(raw: optionsEnum.identifier).\(raw: case_.identifier).rawValue)
            """
        }

        return [
            "\(raw: access)typealias RawValue = \(rawType._syntax)",
            "\(raw: access)var rawValue: RawValue",
            "\(raw: access)init() { self.rawValue = 0 }",
            "\(raw: access)init(rawValue: RawValue) { self.rawValue = rawValue }",
        ] + staticVars
    }
}
