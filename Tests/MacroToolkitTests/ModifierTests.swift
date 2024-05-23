import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import MacroToolkit

final class ModifierTests: XCTestCase {
    func testAccessModifierInit() {
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.private)), .private)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.fileprivate)), .fileprivate)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.internal)), .internal)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.package)), .package)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.public)), .public)
        XCTAssertEqual(AccessModifier(rawValue: .keyword(.open)), .open)
        XCTAssertNil(AccessModifier(rawValue: .identifier("custom")))
    }
    
    func testAccessModifierRawValue() {
        XCTAssertEqual(AccessModifier.private.rawValue, .keyword(.private))
        XCTAssertEqual(AccessModifier.fileprivate.rawValue, .keyword(.fileprivate))
        XCTAssertEqual(AccessModifier.internal.rawValue, .keyword(.internal))
        XCTAssertEqual(AccessModifier.package.rawValue, .keyword(.package))
        XCTAssertEqual(AccessModifier.public.rawValue, .keyword(.public))
        XCTAssertEqual(AccessModifier.open.rawValue, .keyword(.open))
    }
    
    func testAccessModifierName() {
        XCTAssertEqual(AccessModifier.private.name, "private")
        XCTAssertEqual(AccessModifier.fileprivate.name, "fileprivate")
        XCTAssertEqual(AccessModifier.internal.name, "internal")
        XCTAssertEqual(AccessModifier.package.name, "package")
        XCTAssertEqual(AccessModifier.public.name, "public")
        XCTAssertEqual(AccessModifier.open.name, "open")
    }
    
    func testAccessModifierInitWithModifiers() throws {
        let decl: DeclSyntax = """
        private struct Test { }
        """
        let structDecl = decl.as(StructDeclSyntax.self)
        let structObj = Struct.init(rawValue: structDecl!)
        XCTAssertEqual(structObj?.accessLevel, .private)
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
