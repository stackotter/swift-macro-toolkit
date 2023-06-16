import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftDiagnostics
import XCTest
import MacroToolkitExamplePlugin

let testMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self,
    "AddCompletionHandler": AddCompletionHandlerMacro.self,
    "CaseDetection": CaseDetectionMacro.self,
    "addBlocker": AddBlocker.self,
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
}
