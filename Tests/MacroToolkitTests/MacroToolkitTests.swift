import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroToolkitExamplePlugin

let testMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self,
    "CaseDetection": CaseDetectionMacro.self,
]

final class MacroToolkitTests: XCTestCase {
    func testAddAsyncMacro() {
        assertMacroExpansion(
            """
            @Attribute1
            @AddAsync
            @Attribute2
            public
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }
            """,
            expandedSource: """
            @Attribute1
            @Attribute2
            public
            func d(a: Int, for b: String, _ value: Double, completionBlock: @escaping (Bool) -> Void) {
                completionBlock(true)
            }

            @Attribute1
            @Attribute2
            public
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
}
