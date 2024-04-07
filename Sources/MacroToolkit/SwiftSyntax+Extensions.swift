import SwiftSyntax

extension SyntaxProtocol {
    /// Gets the syntax with trivia removed.
    public func withoutTrivia() -> Self {
        var syntax = self
        syntax.leadingTrivia = []
        syntax.trailingTrivia = []
        return syntax
    }
}

extension SyntaxProtocol {
    /// Gets the syntax with a leading newline added.
    public func withLeadingNewline() -> Self {
        with(\.leadingTrivia, leadingTrivia + [.newlines(1)])
    }

    /// Gets the syntax indented using the specified `indentation`.
    public func indented(_ indentation: Indentation = .spaces(4)) -> Self {
        switch indentation {
            case .spaces(let spaces):
                return with(\.leadingTrivia, leadingTrivia + [.spaces(spaces)])
            case .tab:
                return with(\.leadingTrivia, leadingTrivia + [.tabs(1)])
        }
    }
}

/// An indentation style.
public enum Indentation {
    /// n-space indentation.
    case spaces(Int)
    /// Tab-based indentation.
    case tab
}

extension DeclGroupSyntax {
    /// Intended for use in generating user-facing messages. Use a more strongly typed
    /// approach if actually checking the decl kind.
    /// - Parameter article: If `true`, an appropriate article is included before the
    ///   decl kind (e.g. `"a"` or `"an")
    public func textualDeclKind(withArticle article: Bool = false) -> String {
        // Modified from: https://github.com/DougGregor/swift-macro-examples/blob/f61ac7cdca8dc3557e53f86e7e03df1353908d3e/MacroExamplesPlugin/MetaEnumMacro.swift#L121
        switch self {
            case is ActorDeclSyntax:
                return article ? "an actor" : "actor"
            case is ClassDeclSyntax:
                return article ? "a class" : "class"
            case is ExtensionDeclSyntax:
                return article ? "an extension" : "extension"
            case is ProtocolDeclSyntax:
                return article ? "a protocol" : "protocol"
            case is StructDeclSyntax:
                return article ? "a struct" : "struct"
            case is EnumDeclSyntax:
                return article ? "an enum" : "enum"
            default:
                return "unknown"
        }
    }
}

extension FunctionDeclSyntax {
    /// Gets the signature's effect specifiers, or returns a default effect specifiers
    /// syntax (without any specifiers).
    public var effectSpecifiersOrDefault: FunctionEffectSpecifiersSyntax {
        signature.effectSpecifiers
            ?? FunctionEffectSpecifiersSyntax(
                leadingTrivia: " ", asyncSpecifier: nil, throwsSpecifier: nil
            )
    }

    /// Returns the function with or without the `async` modifier (controlled by `isPresent`).
    public func withAsyncModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.effectSpecifiers,
                    effectSpecifiersOrDefault
                        .with(\.asyncSpecifier, isPresent ? "async" : nil)
                )
        )
    }

    /// Returns the function with or without the `throws` modifier (controlled by `isPresent`).
    public func withThrowsModifier(_ isPresent: Bool = true) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.effectSpecifiers,
                    effectSpecifiersOrDefault
                        .with(\.throwsSpecifier, isPresent ? " throws" : nil)
                )
        )
    }

    /// Returns the function, replacing its parameters with the given new parameter list.
    public func withParameters(
        _ parameters: some Sequence<FunctionParameter>
    ) -> FunctionDeclSyntax {
        with(
            \.signature,
            signature
                .with(
                    \.parameterClause,
                    FunctionParameterClauseSyntax(parameters: parameters.asParameterList)
                )
        )
    }

    /// Returns the function, replacing its return type with a new return type.
    public func withReturnType(_ type: Type?) -> FunctionDeclSyntax {
        if let type = type {
            return with(
                \.signature,
                signature
                    .with(
                        \.returnClause,
                        ReturnClauseSyntax(
                            leadingTrivia: " ",
                            type: type._syntax
                        )
                    )
            )
        } else {
            return with(\.signature, signature.with(\.returnClause, nil))
        }
    }

    /// Returns the function, replacing its body with a new code block.
    public func withBody(_ codeBlock: CodeBlockSyntax) -> FunctionDeclSyntax {
        with(
            \.body,
            codeBlock
        )
    }

    /// Returns the function, replacing its body with a collection of expressions.
    public func withBody(_ exprs: [ExprSyntax]) -> FunctionDeclSyntax {
        with(
            \.body,
            CodeBlockSyntax(exprs)
        )
    }

    /// Returns the function, replacing its attributes with a new collection of attributes.
    public func withAttributes(_ attributes: [AttributeListElement]) -> FunctionDeclSyntax {
        with(
            \.attributes,
            attributes.asAttributeList
        )
    }

    /// Returns the function with a leading blank line.
    public func withLeadingBlankLine() -> FunctionDeclSyntax {
        with(
            \.leadingTrivia,
            .newlines(2)
        )
    }
}

extension CodeBlockSyntax {
    /// Creates a code block from an array of expressions.
    public init(_ exprs: [ExprSyntax]) {
        self.init(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax(
                exprs.map { expr in
                    CodeBlockItemSyntax(item: .expr(expr))
                }
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
    }
}

extension DeclGroupSyntax {
    /// Gets whether a declaration group has the `public` access level modifier.
    public var isPublic: Bool {
        modifiers.contains { $0.name.tokenKind == .keyword(.public) } == true
    }
}

extension ExprSyntaxProtocol {
    public var parenthesized: TupleExprSyntax {
        TupleExprSyntax(
            leftParen: .leftParenToken(),
            rightParen: .rightParenToken(),
            elementsBuilder: { LabeledExprSyntax(expression: self) }
        )
    }
}
