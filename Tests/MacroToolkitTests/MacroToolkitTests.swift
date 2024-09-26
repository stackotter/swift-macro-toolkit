import InlineSnapshotTesting
import MacroTesting
import MacroToolkit
import MacroToolkitExamplePlugin
import SwiftSyntax
import SwiftSyntaxMacros
import XCTest

let testMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self,
    "AddCompletionHandler": AddCompletionHandlerMacro.self,
    "CaseDetection": CaseDetectionMacro.self,
    "addBlocker": AddBlockerMacro.self,
    "MyOptionSet": OptionSetMacro.self,
    "MetaEnum": MetaEnumMacro.self,
    "CustomCodable": CustomCodableMacro.self,
    "CodableKey": CodableKeyMacro.self,
    "DictionaryStorage": DictionaryStorageMacro.self,
    "AddAsyncAllMembers": AddAsyncAllMembersMacro.self,
]

final class MacroToolkitTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            macros: testMacros
        ) {
            isRecording = false
            super.invokeTest()
        }
    }

    func testAddAsyncMacro() {
        assertMacro {
            """
            @Before
            @AddAsync
            @After
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }
            """
        } expansion: {
            """
            @Before
            @After
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }

            @Before
            @After
            func d(a: Int, for b: String, _ value: Double) async -> Bool {
                await withCheckedContinuation { continuation in
                    d(a: a, for: b, value) { returnValue in
                        continuation.resume(returning: returnValue)
                    }
                }
            }
            """
        }
    }

    func testAddCompletionHandlerMacro() {
        assertMacro {
            """
            @Before
            @AddCompletionHandler
            @After
            func f(a: Int, for b: String, _ value: Double) async -> String {
                return b
            }
            """
        } expansion: {
            """
            @Before
            @After
            func f(a: Int, for b: String, _ value: Double) async -> String {
                return b
            }

            @Before
            @After
            func f(a: Int, for b: String, _ value: Double, completionHandler: @escaping (String) -> Void) {
                Task {
                    completionHandler(
                        await f(a: a, for: b, value)
                    )
                }
            }
            """
        }
    }

    func testCaseDetectionMacro() {
        assertMacro {
            """
            @CaseDetection
            enum Colours {
                case red, gray(darkness: Int)
            }

            @CaseDetection
            enum Colours: Int {
                case red = 1, green = 2
                case blue
            }
            """
        } expansion: {
            """
            enum Colours {
                case red, gray(darkness: Int)

                var isRed: Bool {
                    if case .red = self {
                        return true
                    }

                    return false
                }

                var isGray: Bool {
                    if case .gray = self {
                        return true
                    }

                    return false
                }
            }
            enum Colours: Int {
                case red = 1, green = 2
                case blue

                var isRed: Bool {
                    if case .red = self {
                        return true
                    }

                    return false
                }

                var isGreen: Bool {
                    if case .green = self {
                        return true
                    }

                    return false
                }

                var isBlue: Bool {
                    if case .blue = self {
                        return true
                    }

                    return false
                }
            }
            """
        }
    }

    func testAddBlockerMacro() {
        assertMacro {
            """
            #addBlocker(1 + 2 * 3)
            """
        } diagnostics: {
            """
            #addBlocker(1 + 2 * 3)
                          ╰─ ⚠️ blocked an add; did you mean to subtract?
                             ✏️ use '-'
            """
        } fixes: {
            """
            #addBlocker(1 - 2 * 3)
            """
        } expansion: {
            """
            1 - 2 * 3
            """
        }
    }

    func testOptionSetMacro() {
        assertMacro {
            """
            @MyOptionSet<UInt8>
            struct ShippingOptions {
                private enum Options: Int {
                    case nextDay
                    case secondDay
                    case priority
                    case standard
                }

                static let express: ShippingOptions = [.nextDay, .secondDay]
                static let all: ShippingOptions = [.express, .priority, .standard]
            }
            """
        } expansion: {
            """
            struct ShippingOptions {
                private enum Options: Int {
                    case nextDay
                    case secondDay
                    case priority
                    case standard
                }

                static let express: ShippingOptions = [.nextDay, .secondDay]
                static let all: ShippingOptions = [.express, .priority, .standard]

                typealias RawValue = UInt8

                var rawValue: RawValue

                init() {
                    self.rawValue = 0
                }

                init(rawValue: RawValue) {
                    self.rawValue = rawValue
                }

                static let nextDay: Self =
                    Self(rawValue: 1 << Options.nextDay.rawValue)

                static let secondDay: Self =
                    Self(rawValue: 1 << Options.secondDay.rawValue)

                static let priority: Self =
                    Self(rawValue: 1 << Options.priority.rawValue)

                static let standard: Self =
                    Self(rawValue: 1 << Options.standard.rawValue)
            }

            extension ShippingOptions: OptionSet {
            }
            """
        }
    }

    func testMetaEnumMacro() {
        assertMacro {
            """
            @MetaEnum
            public enum Color {
                case red, green, blue
                case gray(darkness: Float)
            }
            """
        } expansion: {
            """
            public enum Color {
                case red, green, blue
                case gray(darkness: Float)

                public enum Meta {
                    case red
                    case green
                    case blue
                    case gray
                    public init(_ __macro_local_6parentfMu_: Color) {
                        switch __macro_local_6parentfMu_ {
                            case .red:
                        self = .red
                    case .green:
                        self = .green
                    case .blue:
                        self = .blue
                    case .gray:
                        self = .gray
                        }
                    }
                }
            }
            """
        }
    }

    func testCustomCodableMacro() {
        assertMacro {
            """
            @CustomCodable
            struct CustomCodableString: Codable {
                @CodableKey(name: "OtherName")
                var propertyWithOtherName: String

                var propertyWithSameName: Bool

                func randomFunction() {}
            }
            """
        } expansion: {
            """
            struct CustomCodableString: Codable {
                var propertyWithOtherName: String

                var propertyWithSameName: Bool

                func randomFunction() {}

                enum CodingKeys: String, CodingKey {
                    case propertyWithOtherName = "OtherName"
                    case propertyWithSameName
                }
            }
            """
        }
    }

    func testDictionaryStorageMacro() {
        assertMacro {
            """
            @DictionaryStorage
            struct Point {
                var x: Int = 1
                var y: Int = 2
            }
            """
        } expansion: {
            """
            struct Point {
                var x: Int {
                    get {
                        _storage["x", default: 1] as! Int
                    }
                    set {
                        _storage["x"] = newValue
                    }
                }
                var y: Int {
                    get {
                        _storage["y", default: 2] as! Int
                    }
                    set {
                        _storage["y"] = newValue
                    }
                }

                var _storage: [String: Any] = [:]
            }
            """
        }
    }

    func testNumericLiteralParsing() {
        let octalLiteral: ExprSyntax = "-0o600_015"
        let binaryLiteral: ExprSyntax = "0b01_10__11"
        let hexLiteral: ExprSyntax = "0xf_E"
        let decimalLiteral: ExprSyntax = "1507"
        XCTAssertEqual(IntegerLiteral(octalLiteral)?.value, -0o600_015)
        XCTAssertEqual(IntegerLiteral(binaryLiteral)?.value, 0b01_10__11)
        XCTAssertEqual(IntegerLiteral(hexLiteral)?.value, 0xfE)
        XCTAssertEqual(IntegerLiteral(decimalLiteral)?.value, 1507)

        let decimalFloatLiteral: ExprSyntax = "5_00_.01_00"
        let hexFloatLiteral: ExprSyntax = "-0xFp-2_"  // yep, that's valid Swift lol
        let hexFloatLiteralWithFractional: ExprSyntax = "-0xF.0f_ep-2_"
        XCTAssertEqual(FloatLiteral(decimalFloatLiteral)?.value, 5_00_.01_00)
        XCTAssertEqual(FloatLiteral(hexFloatLiteral)?.value, -0xFp-2_)
        XCTAssertEqual(
            FloatLiteral(hexFloatLiteralWithFractional)?.value, -0xF.0f_ep-2_, "Fair enough")
    }

    func testStringLiteralParsing() {
        let basicLiteral: ExprSyntax = """
            "Hello, world!"
            """
        let literalWithEscapeSequences: ExprSyntax = #"""
            "My literal has \t a tab in the middle\n and a random newline \u{2023} \0 \r \\ \" \'"
            """#
        let multilineLiteral: ExprSyntax = #"""
            """
            This is a multiline literal!
            """
            """#
        let rawLiteral: ExprSyntax = ###"""
            ##"Hi \(name) \n \t \#t \##t \#(test)"##
            """###
        let literalWithInterpolation: ExprSyntax = #"""
            "Hi \(name)"
            """#

        assertInlineSnapshot(of: StringLiteral(basicLiteral)?.value, as: .description) {
            """
            Hello, world!
            """
        }

        assertInlineSnapshot(of: StringLiteral(literalWithEscapeSequences)?.value, as: .dump) {
            #"""
            - "My literal has \t a tab in the middle\n and a random newline ‣ \0 \r \\ \" \'"

            """#
        }

        XCTAssertEqual(
            StringLiteral(rawLiteral)?.value,
            ##"Hi \(name) \n \t \#t \##t \#(test)"##
        )
        XCTAssertEqual(
            StringLiteral(multilineLiteral)?.value,
            """
            This is a multiline literal!
            """
        )

        if let literal = StringLiteral(literalWithInterpolation) {
            XCTAssertEqual(
                literal.value,
                nil
            )
        } else {
            XCTFail("Failed to wrap string literal with interpolation")
        }
    }

    func testRegexLiteralParsing() {
        let basicLiteral: ExprSyntax = """
            /abc/
            """

        // TODO: Figure out a more precise way to test regex literal parsing
        XCTAssert((try? RegexLiteral(basicLiteral)?.regexValue()) != nil)
    }

    func testBooleanLiteralParsing() {
        let trueLiteral: ExprSyntax = "true"
        let falseLiteral: ExprSyntax = "false"

        XCTAssertEqual(BooleanLiteral(trueLiteral)?.value, true)
        XCTAssertEqual(BooleanLiteral(falseLiteral)?.value, false)
    }

    func testNilLiteralParsing() {
        let nilLiteral: ExprSyntax = "nil"

        // Pretty cursed
        XCTAssert(NilLiteral(nilLiteral)?.value != nil)
    }

    func testQuotedVariableIdentifier() {
        let decl: DeclSyntax = """
            var `default`: String
            """

        guard let variable = Decl(decl).asVariable else {
            XCTFail("Expected decl to be variable")
            return
        }

        XCTAssertEqual(variable.identifiers[0], "default")
    }

    func testPropertyParsing() {
        let decl: DeclSyntax = """
            struct MyStruct {
                var a: String, b: Int = 2
                @MyMacro
                var c, d: Int
                var e: Float {
                    1.0
                }
                @MyPropertyWrapper
                var f = 2
                let g = ""
                @MyMacro
                var (h, i) = (1.0, [])
                var ((j, (k, l)), m): ((Int, (String, Float)), Int) = ((1, ("abc", 2)), 3)
                lazy var n = [1, 2.5]
            }
            """

        guard let declGroup = decl.as(StructDeclSyntax.self).map(Struct.init) else {
            XCTFail("Expected decl to be decl group")
            return
        }

        // TODO: Make exprs and types equatable, will have to decide how whitespace
        //   is treated. Easiest option would of course be to do text based comparison.
        XCTAssertEqual(declGroup.properties.count, 14)

        /// Type annotation in a multi-binding declaration.
        let a = declGroup.properties[0]
        XCTAssertEqual(a.identifier, "a")
        XCTAssertEqual(a.type?.description, "String")
        XCTAssertEqual(a.initialValue.debugDescription, "nil")
        XCTAssertEqual(a.isStored, true)
        XCTAssertEqual(a.isLazy, false)
        XCTAssertEqual(a.attributes.count, 0)
        XCTAssertEqual(a.keyword, "var")
        // Assignment in a multi-binding declaration.
        let b = declGroup.properties[1]
        XCTAssertEqual(b.identifier, "b")
        XCTAssertEqual(b.type?.description, "Int")
        XCTAssertEqual(b.initialValue?.asIntegerLiteral?.value, 2)

        // The type of `c` should be inferred to be the same as `d` (`Int`), since `c`
        // doesn't have an annotation. The attribute should be ignored as it isn't
        // attached to either of the properties, just the declaration of both together.
        let c = declGroup.properties[2]
        XCTAssertEqual(c.identifier, "c")
        XCTAssertEqual(c.type?.description, "Int")
        XCTAssertEqual(c.initialValue.debugDescription, "nil")
        XCTAssertEqual(c.attributes.count, 0)
        // Simple annotated binding in a multi-binding declaration.
        let d = declGroup.properties[3]
        XCTAssertEqual(d.identifier, "d")
        XCTAssertEqual(d.type?.description, "Int")
        XCTAssertEqual(d.initialValue.debugDescription, "nil")
        XCTAssertEqual(d.attributes.count, 0)

        // Simple annotated binding in a single-binding declaration.
        let e = declGroup.properties[4]
        XCTAssertEqual(e.identifier, "e")
        XCTAssertEqual(e.type?.description, "Float")
        XCTAssertEqual(e.initialValue.debugDescription, "nil")
        XCTAssertEqual(e.isStored, false)
        XCTAssert(e.getter != nil)
        XCTAssert(e.setter == nil)

        // Inferring a type from a literal.
        let f = declGroup.properties[5]
        XCTAssertEqual(f.identifier, "f")
        XCTAssertEqual(f.type?.description, "Int")
        XCTAssertEqual(f.initialValue?.asIntegerLiteral?.value, 2)
        XCTAssertEqual(f.attributes.count, 1)
        // Same as `f` but with a string literal.
        let g = declGroup.properties[6]
        XCTAssertEqual(g.identifier, "g")
        XCTAssertEqual(g.type?.description, "String")
        XCTAssertEqual(g.initialValue?.asStringLiteral?.value, "")
        XCTAssertEqual(g.keyword, "let")

        // Tuple binding with types inferred from literals. The attribute should be
        // ignored as it isn't attached to either of the properties, just the declaration
        // of both together.
        let h = declGroup.properties[7]
        XCTAssertEqual(h.identifier, "h")
        XCTAssertEqual(h.type?.description, "Double")
        XCTAssertEqual(h.initialValue?.asFloatLiteral?.value, 1.0)
        XCTAssertEqual(h.attributes.count, 0)
        let i = declGroup.properties[8]
        XCTAssertEqual(i.identifier, "i")
        XCTAssertEqual(i.type?.description, "Array<Any>")
        XCTAssertEqual(i.initialValue?._syntax.description, "[]")
        XCTAssertEqual(i.attributes.count, 0)

        // A horrible nested annotated tuple binding with a literal initial value.
        let j = declGroup.properties[9]
        XCTAssertEqual(j.identifier, "j")
        XCTAssertEqual(j.type?.description, "Int")
        XCTAssertEqual(j.initialValue?.asIntegerLiteral?.value, 1)
        let k = declGroup.properties[10]
        XCTAssertEqual(k.identifier, "k")
        XCTAssertEqual(k.type?.description, "String")
        XCTAssertEqual(k.initialValue?.asStringLiteral?.value, "abc")
        let l = declGroup.properties[11]
        XCTAssertEqual(l.identifier, "l")
        XCTAssertEqual(l.type?.description, "Float")
        XCTAssertEqual(l.initialValue?.asIntegerLiteral?.value, 2)
        let m = declGroup.properties[12]
        XCTAssertEqual(m.identifier, "m")
        XCTAssertEqual(m.type?.description, "Int")
        XCTAssertEqual(m.initialValue?.asIntegerLiteral?.value, 3)

        // Inferring the type of a non-empty array literal expression.
        let n = declGroup.properties[13]
        XCTAssertEqual(n.identifier, "n")
        XCTAssertEqual(n.type?.description, "Array<Double>")
        XCTAssertEqual(n.initialValue?._syntax.description, "[1, 2.5]")
        XCTAssertEqual(n.isLazy, true)
    }

    func testAsyncInterfaceMacro() throws {
        assertMacro {
            """
            protocol API {
                @AddAsync
                func request(completion: (Int) -> Void)
            }
            """
        } expansion: {
            """
            protocol API {
                func request(completion: (Int) -> Void)

                func request() async -> Int
            }
            """
        }
    }

    func testAsyncInterfaceAllMembersMacro() throws {
        assertMacro {
            """
            @AddAsyncAllMembers
            protocol API {
                func request1(completion: (Int) -> Void)
                func request2(completion: (String) -> Void)
            }
            """
        } expansion: {
            """
            protocol API {
                func request1(completion: (Int) -> Void)
                func request2(completion: (String) -> Void)

                func request1() async -> Int

                func request2() async -> String
            }
            """
        }
    }
    func testAsyncImplementationMacro() throws {
        assertMacro {
            """
            struct Client {
                @AddAsync
                func request1(completion: (Int) -> Void) {
                    completion(0)
                }
            }
            """
        } expansion: {
            """
            struct Client {
                func request1(completion: (Int) -> Void) {
                    completion(0)
                }

                func request1() async -> Int {
                    await withCheckedContinuation { continuation in
                        request1() { returnValue in
                            continuation.resume(returning: returnValue)
                        }
                    }
                }
            }
            """
        }
    }
    func testAsyncImplementationAllMembersMacro() throws {
        assertMacro {
            """
            @AddAsyncAllMembers
            struct Client {
                func request1(completion: (Int) -> Void) {
                    completion(0)
                }
                func request2(completion: (String) -> Void) {
                    completion("")
                }
            }
            """
        } expansion: {
            """
            struct Client {
                func request1(completion: (Int) -> Void) {
                    completion(0)
                }
                func request2(completion: (String) -> Void) {
                    completion("")
                }

                func request1() async -> Int {
                    await withCheckedContinuation { continuation in
                        request1() { returnValue in
                            continuation.resume(returning: returnValue)
                        }
                    }
                }

                func request2() async -> String {
                    await withCheckedContinuation { continuation in
                        request2() { returnValue in
                            continuation.resume(returning: returnValue)
                        }
                    }
                }
            }
            """
        }
    }
}
