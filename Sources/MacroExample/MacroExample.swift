@attached(peer, names: overloaded)
public macro AddAsync() =
    #externalMacro(module: "MacroExampleMacros", type: "AddAsyncMacro")
