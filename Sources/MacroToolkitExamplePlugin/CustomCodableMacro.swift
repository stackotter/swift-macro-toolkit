import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

// Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/CustomCodable.swift
public struct CustomCodableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let decl = DeclGroup(declaration)

        let cases = decl.members.compactMap(\.asVariable).compactMap { (variable) -> String? in
            guard let propertyName = destructureSingle(variable.identifiers) else {
                return nil
            }

            if let customKeyMacro = variable.attributes.first(called: "CodableKey") {
                guard
                    let attribute = customKeyMacro.asMacroAttribute,
                    let customKeyValue = destructureSingle(attribute.arguments)
                else {
                    return nil
                }

                return "case \(propertyName) = \(customKeyValue._syntax)"
            } else {
                return "case \(propertyName)"
            }
        }

        let codingKeys: DeclSyntax =
            """
            enum CodingKeys: String, CodingKey {
                \(raw: cases.joined(separator: "\n"))
            }
            """

        return [codingKeys]
    }
}
