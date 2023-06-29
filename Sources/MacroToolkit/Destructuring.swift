// TODO: Figure out a destructuring implementation that uses variadic generics (tricky without same type requirements)
public func destructure<Element>(_ elements: some Sequence<Element>) -> ()? {
    let array = Array(elements)
    guard array.count == 0 else {
        return nil
    }
    return ()
}

/// Destructures the given `elements` into a single element if there is exactly one element.
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

public func destructure(_ type: SimpleType) -> (String, ())? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: SimpleType) -> (String, (Type))? {
    destructureSingle(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: SimpleType) -> (String, (Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: SimpleType) -> (String, (Type, Type, Type, Type, Type, Type))? {
    destructure(type.genericArguments ?? []).map { arguments in
        (type.name, arguments)
    }
}

public func destructure(_ type: FunctionType) -> ((), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

/// Named differently to allow type inference to still work correctly (single element tuples
/// are weird in Swift).
public func destructureSingle(_ type: FunctionType) -> ((Type), Type)? {
    destructureSingle(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

public func destructure(_ type: FunctionType) -> ((Type, Type, Type, Type, Type, Type), Type)? {
    destructure(type.parameters).map { parameters in
        (parameters, type.returnType)
    }
}

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
