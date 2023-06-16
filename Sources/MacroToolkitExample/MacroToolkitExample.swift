@attached(peer, names: overloaded)
public macro AddAsync() =
    #externalMacro(module: "MacroToolkitExamplePlugin", type: "AddAsyncMacro")
