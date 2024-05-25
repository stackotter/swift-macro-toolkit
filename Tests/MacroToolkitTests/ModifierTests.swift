import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import MacroToolkit

final class ModifierTests: XCTestCase {
    func testAccessModifierInit() {
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.private)), .private)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.public)), .public)
        XCTAssertNil(AccessModifier(rawValue: .identifier("custom")))
    }

    func testAccessModifierRawValue() {
        XCTAssertEqual(AccessModifier.private.rawValue, .keyword(.private))
        XCTAssertEqual(AccessModifier.public.rawValue, .keyword(.public))
    }

    func testAccessModifierName() {
        XCTAssertEqual(AccessModifier.private.name, "private")
        XCTAssertEqual(AccessModifier.open.name, "open")
    }

    func testAccessModifierInitWithModifiers() throws {
        let decl: DeclSyntax = """
            private struct Test { }
            """
        let structDecl = decl.as(StructDeclSyntax.self)
        let structObj = Struct(structDecl!)
        XCTAssertEqual(structObj.accessLevel, .private)
    }

    func testDeclarationContextModifierInit() {
        XCTAssertEqual(DeclarationContextModifier(rawValue: .keyword(.static)), .static)
        XCTAssertEqual(DeclarationContextModifier(rawValue: .keyword(.class)), .class)
        XCTAssertNil(DeclarationContextModifier(rawValue: .identifier("custom")))
    }

    func testDeclarationContextModifierRawValue() {
        XCTAssertEqual(DeclarationContextModifier.static.rawValue, .keyword(.static))
        XCTAssertEqual(DeclarationContextModifier.class.rawValue, .keyword(.class))
    }
}
