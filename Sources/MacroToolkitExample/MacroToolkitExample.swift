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
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddBlockerMacro")

@attached(member, names: arbitrary)
@attached(extension)
public macro MyOptionSet<RawType>() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "OptionSetMacro")

@attached(member, names: named(Meta))
public macro MetaEnum() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "MetaEnumMacro")

@attached(member)
public macro CodableKey(name: String) =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "CodableKeyMacro")

@attached(member, names: named(CodingKeys))
public macro CustomCodable() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "CustomCodableMacro")

@attached(accessor)
@attached(member, names: named(_storage))
@attached(memberAttribute)
public macro DictionaryStorage() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "DictionaryStorageMacro")

@attached(member, names: arbitrary)
public macro AddAsyncAllMembers() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddAsyncAllMembersMacro")
