import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftDiagnostics
import XCTest
import MacroToolkitExamplePlugin
import SwiftSyntax
import MacroToolkit

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
]

final class MacroToolkitTests: XCTestCase {
    func testAddAsyncMacro() {
        assertMacroExpansion(
            """
            @Before
            @AddAsync
            @After
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }
            """,
            expandedSource: """
            @Before
            @After
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }

            @Before
            @After
            func d(a: Int, for b: String, _ value: Double)  async -> Bool {
                await withCheckedContinuation { continuation in
                    d(a: a, for: b, value) { returnValue in
                        continuation.resume(returning: returnValue)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testAddCompletionHandlerMacro() {
        assertMacroExpansion(
            """
            @Before
            @AddCompletionHandler
            @After
            func f(a: Int, for b: String, _ value: Double) async -> String {
                return b
            }
            """,
            expandedSource: """
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
            """,
            macros: testMacros
        )
    }

    func testCaseDetectionMacro() {
        assertMacroExpansion(
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
            """,
            expandedSource: """

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
            """,
            macros: testMacros
        )
    }

    func testAddBlockerMacro() {
        assertMacroExpansion(
            """
            #addBlocker(1 + 2 * 3)
            """,
            expandedSource: """
            1 - 2 * 3
            """,
            diagnostics: [
                DiagnosticSpec(
                    id: MessageID(domain: "ExampleMacros", id: "addBlocker"),
                    message: "blocked an add; did you mean to subtract?",
                    line: 1,
                    column: 15,
                    severity: .warning,
                    fixIts: [
                        FixItSpec(message: "use '-'")
                    ]
                )
            ],
            macros: testMacros
        )
    }

    func testOptionSetMacro() {
        assertMacroExpansion(
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
            """,
            expandedSource: """

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
                    Self (rawValue: 1 << Options.nextDay.rawValue)

                static let secondDay: Self =
                    Self (rawValue: 1 << Options.secondDay.rawValue)

                static let priority: Self =
                    Self (rawValue: 1 << Options.priority.rawValue)

                static let standard: Self =
                    Self (rawValue: 1 << Options.standard.rawValue)
            }

            extension ShippingOptions: OptionSet {
            }
            """,
            macros: testMacros
        )
    }

    func testMetaEnumMacro() {
        assertMacroExpansion(
            """
            @MetaEnum
            public enum Color {
                case red, green, blue
                case gray(darkness: Float)
            }
            """,
            expandedSource: """

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
            """,
            macros: testMacros
        )
    }

    func testCustomCodableMacro() {
        assertMacroExpansion(
            """
            @CustomCodable
            struct CustomCodableString: Codable {
                @CodableKey(name: "OtherName")
                var propertyWithOtherName: String

                var propertyWithSameName: Bool

                func randomFunction() {}
            }
            """,
            expandedSource: """

            struct CustomCodableString: Codable {
                var propertyWithOtherName: String

                var propertyWithSameName: Bool

                func randomFunction() {}

                enum CodingKeys: String, CodingKey {
                    case propertyWithOtherName = "OtherName"
                    case propertyWithSameName
                }
            }
            """,
            macros: testMacros
        )
    }

    func testDictionaryStorageMacro() {
        assertMacroExpansion(
            """
            @DictionaryStorage
            struct Point {
                var x: Int = 1
                var y: Int = 2
            }
            """,
            expandedSource: """

            struct Point {
                var x: Int = 1 {
                    get {
                        _storage["x", default: 1] as! Int
                    }
                    set {
                        _storage["x"] = newValue
                    }
                }
                var y: Int = 2 {
                    get {
                        _storage["y", default: 2] as! Int
                    }
                    set {
                        _storage["y"] = newValue
                    }
                }

                var _storage: [String: Any] = [:]
            }
            """,
            macros: testMacros
        )
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
        let hexFloatLiteral: ExprSyntax = "-0xFp-2_" // yep, that's valid Swift lol
        let hexFloatLiteralWithFractional: ExprSyntax = "-0xF.0f_ep-2_"
        XCTAssertEqual(FloatLiteral(decimalFloatLiteral)?.value, 5_00_.01_00)
        XCTAssertEqual(FloatLiteral(hexFloatLiteral)?.value, -0xFp-2_)
        XCTAssertEqual(FloatLiteral(hexFloatLiteralWithFractional)?.value, -0xF.0f_ep-2_, "Fair enough")
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

        XCTAssertEqual(StringLiteral(basicLiteral)?.value, "Hello, world!")
        XCTAssertEqual(
            StringLiteral(literalWithEscapeSequences)?.value,
            "My literal has \t a tab in the middle\n and a random newline \u{2023} \0 \r \\ \" \'"
        )
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
}
