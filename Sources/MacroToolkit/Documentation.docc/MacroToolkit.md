# ``MacroToolkit``

An expressive toolkit for creating robust macros with minimal boilerplate code. All you need to make
a production-ready macro is an idea.


## Topics

### Articles

- <doc:Destructuring>

### Expressions

Expressions are a core component of Swift syntax. Manipulate them with ease.

- ``Expr``
- ``ExprProtocol``

### Literals

MacroToolkit provides simple wrappers for all possible types of literals. Extract the values of literals with ease.
You'll be glad that you're not parsing `-0xF.0f_ep-2_` yourself (yep that's a valid floating point literal).

- ``LiteralProtocol``
- ``StringLiteral``
- ``IntegerLiteral``
- ``FloatLiteral``
- ``BooleanLiteral``
- ``RegexLiteral``
- ``NilLiteral``

### Declarations

Access members of declaration groups and manipulate all kinds of declarations.

- ``Decl``
- ``DeclGroup``
- ``Struct``

### Variables

Variables can be tedious to parse, but MacroToolkit makes such tasks a walk in the park.

- ``Variable``
- ``VariableBinding``

### Functions

Easily work with function signatures and extract type information with minimal work.

- ``Function``
- ``FunctionParameter``

### Enums

Extract all cases from a declaration without any effort. Handle syntax such as `case a, b, c`
out-of-the-box.

- ``Enum``
- ``EnumCase``
- ``EnumCaseValue``
- ``EnumCaseAssociatedValueParameter``

### Attributes

As a macro author, working with attributes is a common occurence but requires a significant amount of boilerplate code.
Paired with destructuring, MacroToolkit's attribute wrappers provide a simple API for parsing attributes.

- ``Attribute``
- ``MacroAttribute``
- ``AttributeListElement``
- ``ConditionalCompilationBlock``

### Types

Swift has a lot of different ways to express types, which is great for developers, but a nightmare for macro developers.
MacroToolkit makes working with types a breeze. For example, you can easily check whether a type is `Void` even if a user has
written it as `(((((((Void)))))))` (which is a valid way to write `Void`).

- ``Type``
- ``TypeProtocol``
- ``ArrayType``
- ``TupleType``
- ``MemberType``
- ``SimpleType``
- ``MissingType``
- ``FunctionType``
- ``MetatypeType``
- ``OptionalType``
- ``DictionaryType``
- ``SuppressedType``
- ``CompositionType``
- ``PackExpansionType``
- ``PackReferenceType``
- ``ClassRestrictionType``
- ``SomeOrAnyType``
- ``ImplicitlyUnwrappedOptionalType``

### Diagnostics

Rich diagnostics are vital to a enjoyable macro user experience, but they can be quite tedious to generate and are hence
often neglected. MacroToolkit makes creating diagnostics a breeze.

- ``DiagnosticBuilder``
- ``MacroError``
- ``SimpleDiagnosticMessage``

### Destructuring

Destructuring is a powerful feature that allows you to parse syntax with minimal boilerplate code. Learn more by reading
the <doc:Destructuring> article.

- ``DestructuredType``

- ``destructure(_:)-12e8l``
- ``destructureSingle(_:)-1dg2k``
- ``destructure(_:)-2c4y9``
- ``destructure(_:)-65tob``
- ``destructure(_:)-2vkcn``
- ``destructure(_:)-2ooj8``
- ``destructure(_:)-ztug``

- ``destructure(_:)-6saio``
- ``destructureSingle(_:)-9tjyg``
- ``destructure(_:)-1vwqf``
- ``destructure(_:)-365tz``
- ``destructure(_:)-867ko``
- ``destructure(_:)-5joxh``
- ``destructure(_:)-nbe1``

- ``destructure(_:)-3e860``
- ``destructureSingle(_:)-chrb``
- ``destructure(_:)-3xse5``
- ``destructure(_:)-8aio2``
- ``destructure(_:)-560mv``
- ``destructure(_:)-1h0o8``
- ``destructure(_:)-45hpd``

- ``destructure(_:)-180j9``
- ``destructureSingle(_:)-5r8sv``
- ``destructure(_:)-2idom``
- ``destructure(_:)-8g4v5``
- ``destructure(_:)-7o2hx``
- ``destructure(_:)-8m59b``
- ``destructure(_:)-9wc1b``

### Extensions

SwiftSyntax's API isn't built for expressive macro implementation. That's why MacroToolkit provides a set of useful extensions
for working with SwiftSyntax syntax nodes.

- ``SwiftSyntax/DeclGroupSyntax/isPublic``
- ``SwiftSyntax/DeclGroupSyntax/textualDeclKind(withArticle:)``
- ``SwiftSyntax/SyntaxProtocol/indented(_:)``
- ``Indentation``
- ``SwiftSyntax/SyntaxProtocol/withLeadingNewline()``
- ``SwiftSyntax/SyntaxProtocol/withoutTrivia()``
- ``SwiftSyntax/CodeBlockSyntax/init(_:)``
- ``SwiftSyntax/FunctionDeclSyntax/effectSpecifiersOrDefault``
- ``SwiftSyntax/FunctionDeclSyntax/withAsyncModifier(_:)``
- ``SwiftSyntax/FunctionDeclSyntax/withAttributes(_:)``
- ``SwiftSyntax/FunctionDeclSyntax/withBody(_:)-6zcqc``
- ``SwiftSyntax/FunctionDeclSyntax/withBody(_:)-3fm1h``
- ``SwiftSyntax/FunctionDeclSyntax/withLeadingBlankLine()``
- ``SwiftSyntax/FunctionDeclSyntax/withParameters(_:)``
- ``SwiftSyntax/FunctionDeclSyntax/withReturnType(_:)``
- ``SwiftSyntax/FunctionDeclSyntax/withThrowsModifier(_:)``
- ``Swift/Collection/removing(_:)``
- ``Swift/Sequence/asAttributeList``
- ``Swift/Sequence/asParameterList``
- ``Swift/Sequence/asPassthroughArguments``
- ``Swift/Sequence/first(called:)``
- ``Swift/String/initialUppercased``
- ``Swift/Optional/isVoid``
