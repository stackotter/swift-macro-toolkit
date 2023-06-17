import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftDiagnostics
import XCTest
import MacroToolkitExamplePlugin

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

                func randomFunction() {
                }
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
}
