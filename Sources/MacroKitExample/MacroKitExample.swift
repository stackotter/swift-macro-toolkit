@attached(peer, names: overloaded)
public macro AddAsync() =
    #externalMacro(module: "MacroKitExamplePlugin", type: "AddAsyncMacro")
