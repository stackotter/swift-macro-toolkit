import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroToolkitExamplePlugin

let testMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self,
]

final class MacroToolkitTests: XCTestCase {
    func testMacro() {
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
}
