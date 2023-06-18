import SwiftSyntax

/// Wraps an element of an attribute list (either an attribute, or a compile-time
/// compilation block containing attributes to be conditionally compiled).
public enum AttributeListElement {
    case attribute(Attribute)
    case conditionalCompilationBlock(ConditionalCompilationBlock)

    public var attribute: Attribute? {
        switch self {
            case .attribute(let attribute):
                return attribute
            default:
                return nil
        }
    }

    public var conditionalCompilationBlock: ConditionalCompilationBlock? {
        switch self {
            case .conditionalCompilationBlock(let conditionalCompilationBlock):
                return conditionalCompilationBlock
            default:
                return nil
        }
    }
}

extension Sequence where Element == AttributeListElement {
    /// Converts the sequence into the syntax for an attribute list (with each element's
    /// trailing trivia updated appropriately).
    public var asAttributeList: AttributeListSyntax {
        var list = AttributeListSyntax([])
        for attribute in self {
            let element: AttributeListSyntax.Element
            switch attribute {
                case .attribute(let attribute):
                    element = .attribute(attribute._syntax.with(\.trailingTrivia, [.spaces(1)]))
                case .conditionalCompilationBlock(let conditionalCompilationBlock):
                    element = .ifConfigDecl(conditionalCompilationBlock._syntax.with(\.trailingTrivia, [.spaces(1)]))
            }
            list = list.appending(element)
        }
        return list
    }

    public func first(called name: String) -> Attribute? {
        // TODO: How should conditional compilation attributes be handled?
        compactMap(\.attribute).first { attribute in
            attribute.name.asNominalType?.name == name
        }
    }
}

extension Collection where Element == AttributeListElement {
    /// Removes any attributes matching the specified attribute, and returns the result.
    public func removing(_ attribute: AttributeSyntax) -> [AttributeListElement] {
        filter { element in
            element.attribute?._syntax != attribute
        }
    }
}
