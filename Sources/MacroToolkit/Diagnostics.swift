import SwiftSyntax
import SwiftDiagnostics
import Foundation

// TODO: Improve diagnostic generation ergonomics
// Taken from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/Diagnostics.swift
public struct SimpleDiagnosticMessage: DiagnosticMessage, Error {
    public let message: String
    public let diagnosticID: MessageID
    public let severity: DiagnosticSeverity

    public init(message: String, diagnosticID: MessageID, severity: DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }
}

extension SimpleDiagnosticMessage: FixItMessage {
    public var fixItID: MessageID { diagnosticID }
}

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