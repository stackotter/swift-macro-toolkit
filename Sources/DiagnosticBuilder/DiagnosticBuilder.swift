import Foundation
import SwiftDiagnostics
import SwiftSyntax

/// A way to create rich diagnostics with no unnecessary boilerplate code. Only provide the
/// important details and the rest will be given sensible defaults.
public struct DiagnosticBuilder {
    /// The node that the diagnostic will be attached to.
    var node: Syntax
    /// The message that the diagnostic will show.
    var message: String?
    /// The diagnostic id (should be the same for all diagnostics produced by the same codepath).
    var messageID = MessageID(domain: "UnknownDomain", id: "UnknownError")
    /// The fix-its that will be associated with the diagnostics.
    var fixIts: [FixIt] = []
    /// The additional syntax nodes that will be highlighted by the diagnostic.
    var highlights: [Syntax] = []

    /// Defaults to ``DiagnosticSeverity/error``.
    var severity: DiagnosticSeverity = .error

    /// Creates a new builder for a diagnostics related to the given `node`.
    public init(for node: some SyntaxProtocol) {
        self.node = Syntax(node)
    }

    /// Set the message.
    public func message(_ message: String) -> Self {
        var builder = self
        builder.message = message
        return builder
    }

    /// Set the severity.
    public func severity(_ severity: DiagnosticSeverity) -> Self {
        var builder = self
        builder.severity = severity
        return builder
    }

    /// Set the message id.
    public func messageID(_ messageID: MessageID) -> Self {
        var builder = self
        builder.messageID = messageID
        return builder
    }

    /// Add a fix-it suggestion.
    public func fixIt(_ fixIt: FixIt) -> Self {
        var builder = self
        builder.fixIts.append(fixIt)
        return builder
    }

    /// Highlight a syntax node related to the diagnostic.
    public func highlight(_ node: some SyntaxProtocol) -> Self {
        var builder = self
        builder.highlights.append(Syntax(node))
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
        fixIt(
            FixIt(
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

    /// Set the message id (shorthand for ``messageID(_:)``).
    public func messageID(domain: String, id: String) -> Self {
        messageID(MessageID(domain: domain, id: id))
    }

    /// Build the final diagnostic to be emitted. Defaults will be used for any
    /// unset configuration values.
    public func build() -> Diagnostic {
        let messageID = messageID
        return Diagnostic(
            node: node,
            message: SimpleDiagnosticMessage(
                message: message ?? "unspecified error",
                diagnosticID: messageID,
                severity: severity
            ),
            highlights: highlights,
            fixIts: fixIts
        )
    }
}
