import Foundation
import SwiftSyntax

// Possibly replace with the work done for ``Property`` (stealing the docs from here).
/// A variable binding (e.g. the `a: Int = 3` part of `var a: Int = 3`)
public struct VariableBinding {
    public var _syntax: PatternBindingSyntax

    public init(_ syntax: PatternBindingSyntax) {
        _syntax = syntax
    }

    /// Accessors specified along with the binding such as getters and setters.
    ///
    /// ```swift
    /// var a: Int {
    ///     get { // A `get` accessor
    ///         return 0
    ///     }
    ///     set { // A `set` accessor
    ///         print(newValue)
    ///     }
    /// }
    /// ```
    public var accessors: [AccessorDeclSyntax] {
        switch _syntax.accessorBlock?.accessors {
            case .accessors(let block):
                return Array(block)
            case .getter(let getter):
                // TODO: Avoid synthesising syntax here (wouldn't work with diagnostics)
                return [AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) { getter }]
            case .none:
                return []
        }
    }

    /// The identifier defined by the binding if the binding is a simple identifier binding.
    ///
    /// For example, the binding `(a, b) = (1, 2)` doesn't have an `identifier`.
    public var identifier: String? {
        let identifier = _syntax.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        return identifier?.trimmingCharacters(in: CharacterSet(arrayLiteral: "`"))
    }

    /// The type annotation supplied for the binding if any (e.g. the `Int` in `a: Int`).
    public var type: Type? {
        (_syntax.typeAnnotation?.type).map(Type.init)
    }

    /// The initial value given for the variable (e.g. the `4` in `a = 4`).
    public var initialValue: Expr? {
        (_syntax.initializer?.value).map(Expr.init)
    }
}
