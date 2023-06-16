import SwiftSyntax
import SwiftDiagnostics
import Foundation

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

public struct DiagnosticBuilder {
    var node: Syntax
    var message: String?
    var messageID = MessageID(domain: "UnknownDomain", id: "UnknownError")

    /// Defaults to ``DiagnosticSeverity/error``.
    var severity: DiagnosticSeverity = .error

    var fixIts: [FixIt] = []

    public init(for node: some SyntaxProtocol) {
        self.node = Syntax(node)
    }

    public func message(_ message: String) -> Self {
        var builder = self
        builder.message = message
        return builder
    }

    public func severity(_ severity: DiagnosticSeverity) -> Self {
        var builder = self
        builder.severity = severity
        return builder
    }

    public func messageID(_ messageID: MessageID) -> Self {
        var builder = self
        builder.messageID = messageID
        return builder
    }

    public func fixIt(_ fixIt: FixIt) -> Self {
        var builder = self
        builder.fixIts.append(fixIt)
        return builder
    }

    /// Adds a replacement fix-it to the diagnostic. If `messageID` is `nil`, the fix-it will
    /// inherit the current `messageID` set via ``DiagnosticBuilder/messageID(_:)`` (or the default
    /// messageID of `"UnknownDomain", "UnknownError"`).
    public func suggestReplacement(
        _ message: String? = nil,
        messageID: MessageID? = nil,
        severity: DiagnosticSeverity = .error,
        old: some SyntaxProtocol,
        new: some SyntaxProtocol
    ) -> Self {
        fixIt(FixIt(
            message: SimpleDiagnosticMessage(
                message: message ?? "suggested replacement",
                diagnosticID: messageID ?? self.messageID,
                severity: .error
            ),
            changes: [
                FixIt.Change.replace(
                    oldNode: Syntax(old),
                    newNode: Syntax(new)
                )
            ]
        ))
    }

    public func messageID(domain: String, id: String) -> Self {
        messageID(MessageID(domain: domain, id: id))
    }

    public func build() -> Diagnostic {
        let messageID = messageID
        return Diagnostic(
            node: node,
            message: SimpleDiagnosticMessage(
                message: message ?? "unspecified error",
                diagnosticID: messageID,
                severity: severity
            ),
            fixIts: fixIts
        )
    }
}