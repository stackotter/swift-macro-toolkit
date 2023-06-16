@attached(peer, names: overloaded)
public macro AddAsync() =
    #externalMacro(module: "MacroUtilsExamplePlugin", type: "AddAsyncMacro")
