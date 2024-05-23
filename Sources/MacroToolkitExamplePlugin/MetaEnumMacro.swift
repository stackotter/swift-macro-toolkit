import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MetaEnumMacro {
    let parentTypeName: String
    let metaCases: [EnumCase]
    let access: String
    let parentParamName: TokenSyntax

    init(
        node: AttributeSyntax, declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) throws {
        guard let enumDecl = Enum(declaration) else {
            throw DiagnosticsError(diagnostics: [
                CaseMacroDiagnostic.notAnEnum(declaration).diagnose(at: Syntax(node))
            ])
        }

        parentTypeName = enumDecl.identifier
        
        access = enumDecl.accessLevel == .public ? "public " : ""

        metaCases = enumDecl.cases.map { case_ in
            case_.withoutValue()
        }

        parentParamName = context.makeUniqueName("parent")
    }

    func makeMetaEnum() -> DeclSyntax {
        let caseDecls = metaCases.map { childCase in
            "case \(childCase.identifier)"
        }.joined(separator: "\n")

        return
            """
            \(raw: access)enum Meta {
                \(raw: caseDecls)
                \(makeMetaInit())
            }
            """
    }

    func makeMetaInit() -> DeclSyntax {
        let caseStatements = metaCases.map { metaCase in
            """
            case .\(metaCase.identifier):
                self = .\(metaCase.identifier)
            """
        }.joined(separator: "\n")

        return
            """
            \(raw: access)init(_ \(parentParamName): \(raw: parentTypeName)) {
                switch \(parentParamName) {
                    \(raw: caseStatements)
                }
            }
            """
    }
}

extension MetaEnumMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let macro = try MetaEnumMacro(node: node, declaration: declaration, context: context)

        return [macro.makeMetaEnum()]
    }
}

enum CaseMacroDiagnostic {
    case notAnEnum(DeclGroupSyntax)

    var message: String {
        switch self {
            case .notAnEnum(let decl):
                return
                    "'@MetaEnum' can only be attached to an enum, not \(decl.textualDeclKind(withArticle: true))"
        }
    }

    func diagnose(at node: Syntax) -> Diagnostic {
        DiagnosticBuilder(for: node)
            .message(message)
            .messageID(MessageID(domain: "MetaEnum", id: Mirror(reflecting: self).children.first?.label ?? "\(self)"))
            .build()
    }
}
