import SwiftSyntax
import SwiftSyntaxMacros
import MacroToolkit

public struct DictionaryStorageMacro {}

extension DictionaryStorageMacro: AccessorMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: Declaration,
        in context: Context
    ) throws -> [AccessorDeclSyntax] {
        guard
            let variable = Variable(declaration),
            let binding = destructureSingle(variable.bindings),
            let type = binding.type,
            let identifier = binding.identifier
        else {
            return []
        }

        // Ignore the "_storage" variable.
        guard identifier != "_storage" else {
            return []
        }

        guard let defaultValue = binding.initialValue else {
            throw MacroError("stored property must have an initializer")
        }

        return [
            """
            get {
                _storage[\(literal: identifier), default: \(defaultValue._syntax)] as! \(type._syntax)
            }
            """,
            """
            set {
                _storage[\(literal: identifier)] = newValue
            }
            """,
        ]
    }
}

extension DictionaryStorageMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let storage: DeclSyntax = "var _storage: [String: Any] = [:]"
        return [
            storage.indented().withLeadingNewline()
        ]
    }
}

extension DictionaryStorageMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variable = Variable(member), variable.isStoredProperty == true else {
            return []
        }

        return [
            Attribute(named: "DictionaryStorage")
                ._syntax
                .indented()
                .withLeadingNewline()
        ]
    }
}
