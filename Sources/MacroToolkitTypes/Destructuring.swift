// TODO: Figure out a destructuring implementation that uses variadic generics (tricky without same type requirements)
/// Destructures the given `elements` into a tuple of 0 elements if there are exactly 0 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> ()? {
    let array = Array(elements)
    guard array.count == 0 else {
        return nil
    }
    return ()
}

/// Destructures the given `elements` into a single element if there is exactly one element.
///
/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle<Element>(_ elements: some Sequence<Element>) -> (Element)? {
    let array = Array(elements)
    guard array.count == 1 else {
        return nil
    }
    return (array[0])
}

/// Destructures the given `elements` into a tuple of 2 elements if there are exactly 2 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element)? {
    let array = Array(elements)
    guard array.count == 2 else {
        return nil
    }
    return (array[0], array[1])
}

/// Destructures the given `elements` into a tuple of 3 elements if there are exactly 3 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> (Element, Element, Element)?
{
    let array = Array(elements)
    guard array.count == 3 else {
        return nil
    }
    return (array[0], array[1], array[2])
}

/// Destructures the given `elements` into a tuple of 4 elements if there are exactly 4 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> (
    Element, Element, Element, Element
)? {
    let array = Array(elements)
    guard array.count == 4 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3])
}

/// Destructures the given `elements` into a tuple of 5 elements if there are exactly 5 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> (
    Element, Element, Element, Element, Element
)? {
    let array = Array(elements)
    guard array.count == 5 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3], array[4])
}

/// Destructures the given `elements` into a tuple of 6 elements if there are exactly 6 elements.
public func destructure<Element>(_ elements: some Sequence<Element>) -> (
    Element, Element, Element, Element, Element, Element
)? {
    let array = Array(elements)
    guard array.count == 6 else {
        return nil
    }
    return (array[0], array[1], array[2], array[3], array[4], array[5])
}

/// Destructures the given `type` into a name and a tuple of 0 generic type parameters if there are exactly 0 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, ())? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and 1 generic type parameter if there is exactly 1 generic type parameter.
///
/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: SimpleType) -> (String, (Type))? {
    destructureSingle(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and a tuple of 2 generic type parameters if there are exactly 2 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, (Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and a tuple of 3 generic type parameters if there are exactly 3 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and a tuple of 4 generic type parameters if there are exactly 4 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and a tuple of 5 generic type parameters if there are exactly 5 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a name and a tuple of 6 generic type parameters if there are exactly 6 generic type parameters.
public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Destructures the given `type` into a tuple of 0 parameter types and a return type if there are exactly 0 parameters.
public func destructure(_ type: FunctionType) -> ((), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a parameter type and a return type if there is exactly 1 parameter.
///
/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: FunctionType) -> ((Type), Type)? {
    destructureSingle(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a tuple of 2 parameter types and a return type if there are exactly 2 parameters.
public func destructure(_ type: FunctionType) -> ((Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a tuple of 3 parameter types and a return type if there are exactly 3 parameters.
public func destructure(_ type: FunctionType) -> ((Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a tuple of 4 parameter types and a return type if there are exactly 4 parameters.
public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a tuple of 5 parameter types and a return type if there are exactly 5 parameters.
public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a tuple of 6 parameter types and a return type if there are exactly 6 parameters.
public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<()>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
///
/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: Type) -> DestructuredType<(Type)>? {
    if let type = type.asSimpleType {
        return destructureSingle(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructureSingle(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<(Type, Type)>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type)>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type, Type)>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type, Type, Type)>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// Destructures the given `type` into a ``DestructuredType`` for easy pattern matching.
public func destructure(_ type: Type) -> DestructuredType<(Type, Type, Type, Type, Type, Type)>? {
    if let type = type.asSimpleType {
        return destructure(type).map { destructured in
            .simple(name: destructured.0, genericArguments: destructured.1)
        }
    } else if let type = type.asFunctionType {
        return destructure(type).map { destructured in
            .function(parameterTypes: destructured.0, returnType: destructured.1)
        }
    } else {
        return nil
    }
}

/// A destructured type (e.g. `Result<Success, Failure>` becomes `.simple(name: "Result", genericArguments: ("Success", "Failure"))`).
public enum DestructuredType<TypeList> {
    /// A simple type (often referred to as a nominal type) such as `Int` or `Array<String>`.
    case simple(name: String, genericArguments: TypeList)
    /// A function type such as `(Int) -> Void`.
    case function(parameterTypes: TypeList, returnType: Type)
}
