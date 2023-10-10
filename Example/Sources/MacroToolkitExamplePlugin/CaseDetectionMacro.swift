import SwiftSyntax
import SwiftSyntaxMacros
import MacroToolkit

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/CaseDetectionMacro.swift
public struct CaseDetectionMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let enum_ = Enum(declaration) else {
            throw MacroError("@CaseDetectionMacro can only be attached to enum declarations")
    	}

        return enum_.cases
            .map { ($0.identifier, $0.identifier.initialUppercased) }
            .map { original, uppercased in
                """
                var is\(raw: uppercased): Bool {
                    if case .\(raw: original) = self {
                        return true
                    }

                    return false
                }
                """
            }
    }
}