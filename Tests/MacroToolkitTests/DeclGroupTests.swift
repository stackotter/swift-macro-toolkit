import SwiftSyntax
import XCTest

@testable import MacroToolkit

final class DeclGroupTests: XCTestCase {
    func testStructInitialization() throws {
        let decl: DeclSyntax = """
            struct TestStruct { var value: Int }
            """
        let structDecl = decl.as(StructDeclSyntax.self)!
        let testStruct = Struct(structDecl)

        XCTAssertEqual(testStruct.identifier, "TestStruct")
        XCTAssertEqual(testStruct.members.count, 1)
        XCTAssertEqual(testStruct.properties.count, 1)
    }

    func testEnumInitialization() throws {
        let decl: DeclSyntax = """
            enum TestEnum { case caseOne, caseTwo }
            """
        let enumDecl = decl.as(EnumDeclSyntax.self)!
        let testEnum = Enum(enumDecl)

        XCTAssertEqual(testEnum.identifier, "TestEnum")
        XCTAssertEqual(testEnum.members.count, 1)
        XCTAssertEqual(testEnum.cases.count, 2)
    }

    func testClassInitialization() throws {
        let decl: DeclSyntax = """
            class TestClass { var value: Int }
            """
        let classDecl = decl.as(ClassDeclSyntax.self)!
        let testClass = Class(classDecl)

        XCTAssertEqual(testClass.identifier, "TestClass")
        XCTAssertEqual(testClass.members.count, 1)
        XCTAssertEqual(testClass.properties.count, 1)
    }

    func testActorInitialization() throws {
        let decl: DeclSyntax = """
            actor TestActor { var value: Int }
            """
        let actorDecl = decl.as(ActorDeclSyntax.self)!
        let testActor = Actor(actorDecl)

        XCTAssertEqual(testActor.identifier, "TestActor")
        XCTAssertEqual(testActor.members.count, 1)
        XCTAssertEqual(testActor.properties.count, 1)
    }

    func testExtensionInitialization() throws {
        let decl: DeclSyntax = """
            extension TestStruct { func testMethod() {} }
            """
        let extensionDecl = decl.as(ExtensionDeclSyntax.self)!
        let testExtension = Extension(extensionDecl)

        XCTAssertEqual(testExtension.identifier, "TestStruct")
        XCTAssertEqual(testExtension.members.count, 1)
    }

    func testDeclGroupInitialization() throws {
        let structDecl: DeclSyntax = """
            struct TestStruct { var value: Int }
            """
        let structSyntax = structDecl.as(StructDeclSyntax.self)!
        let structDeclGroup = AnyDeclGroup(structSyntax)

        switch structDeclGroup {
            case .struct(let testStruct):
                XCTAssertEqual(testStruct.identifier, "TestStruct")
                XCTAssertEqual(testStruct.members.count, 1)
                XCTAssertEqual(testStruct.properties.count, 1)
            default:
                XCTFail("Expected .struct case")
        }

        let enumDecl: DeclSyntax = """
            enum TestEnum { case caseOne, caseTwo }
            """
        let enumSyntax = enumDecl.as(EnumDeclSyntax.self)!
        let enumDeclGroup = AnyDeclGroup(enumSyntax)

        switch enumDeclGroup {
            case .enum(let testEnum):
                XCTAssertEqual(testEnum.identifier, "TestEnum")
                XCTAssertEqual(testEnum.members.count, 1)
                XCTAssertEqual(testEnum.cases.count, 2)
            default:
                XCTFail("Expected .enum case")
        }

        let classDecl: DeclSyntax = """
            class TestClass { var value: Int }
            """
        let classSyntax = classDecl.as(ClassDeclSyntax.self)!
        let classDeclGroup = AnyDeclGroup(classSyntax)

        switch classDeclGroup {
            case .class(let testClass):
                XCTAssertEqual(testClass.identifier, "TestClass")
                XCTAssertEqual(testClass.members.count, 1)
                XCTAssertEqual(testClass.properties.count, 1)
            default:
                XCTFail("Expected .class case")
        }

        let actorDecl: DeclSyntax = """
            actor TestActor { var value: Int }
            """
        let actorSyntax = actorDecl.as(ActorDeclSyntax.self)!
        let actorDeclGroup = AnyDeclGroup(actorSyntax)

        switch actorDeclGroup {
            case .actor(let testActor):
                XCTAssertEqual(testActor.identifier, "TestActor")
                XCTAssertEqual(testActor.members.count, 1)
                XCTAssertEqual(testActor.properties.count, 1)
            default:
                XCTFail("Expected .actor case")
        }

        let extensionDecl: DeclSyntax = """
            extension TestStruct { func testMethod() {} }
            """
        let extensionSyntax = extensionDecl.as(ExtensionDeclSyntax.self)!
        let extensionDeclGroup = AnyDeclGroup(extensionSyntax)

        switch extensionDeclGroup {
            case .extension(let testExtension):
                XCTAssertEqual(testExtension.identifier, "TestStruct")
                XCTAssertEqual(testExtension.members.count, 1)
            default:
                XCTFail("Expected .extension case")
        }
    }

    func testDeclGroupProtocolExtension() throws {
        let decl: DeclSyntax = """
            public class TestClass: SuperClass, ProtocolOne, ProtocolTwo {
                public var a: Int
                var b: Int
                public static var c: Int
                func method() {}
            }
            """
        let classDecl = decl.as(ClassDeclSyntax.self)!
        let testClass = Class(classDecl)

        XCTAssertEqual(testClass.identifier, "TestClass")
        XCTAssertEqual(testClass.members.count, 4)
        XCTAssertEqual(testClass.properties.count, 3)
        XCTAssertEqual(
            testClass.inheritedTypes.map { $0.description },
            ["SuperClass", "ProtocolOne", "ProtocolTwo"])
        XCTAssertEqual(testClass.accessLevel, .public)
        XCTAssertEqual(testClass.declarationContext, nil)
    }
}
