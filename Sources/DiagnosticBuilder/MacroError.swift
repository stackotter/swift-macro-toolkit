import Foundation

/// A generic macro error. If you are making a widely used macro I'd encourage you
/// to instead provide more detailed diagnostics through the diagnostics API that
/// macros have access to.
public struct MacroError: LocalizedError {
    let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        message
    }
}
