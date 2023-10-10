import SwiftDiagnostics

// Taken from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/Diagnostics.swift
/// A simple diagnostic with a message, id, and severity.
public struct SimpleDiagnosticMessage: DiagnosticMessage, Error {
    /// The human-readable message.
    public let message: String
    /// The unique diagnostic id (should be the same for all diagnostics produced by the same codepath).
    public let diagnosticID: MessageID
    /// The diagnostic's severity.
    public let severity: DiagnosticSeverity

    /// Creates a new diagnostic message.
    public init(message: String, diagnosticID: MessageID, severity: DiagnosticSeverity) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }
}

extension SimpleDiagnosticMessage: FixItMessage {
    /// The unique fix-it id (should be the same for all fix-its produced by the same codepath).
    public var fixItID: MessageID { diagnosticID }
}
