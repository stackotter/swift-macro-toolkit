@attached(peer, names: overloaded)
public macro AddAsync() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddAsyncMacro")

@attached(member, names: arbitrary)
public macro CaseDetection() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "CaseDetectionMacro")

@attached(peer, names: overloaded)
public macro AddCompletionHandler() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddCompletionHandlerMacro")

@freestanding(expression)
public macro addBlocker<T>(_ value: T) -> T =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddBlocker")

@attached(member, names: arbitrary)
@attached(conformance)
public macro MyOptionSet<RawType>() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "OptionSetMacro")