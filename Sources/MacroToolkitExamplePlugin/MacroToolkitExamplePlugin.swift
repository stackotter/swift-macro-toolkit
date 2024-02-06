import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroToolkitExamplePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddAsyncMacro.self,
        AddCompletionHandlerMacro.self,
        CaseDetectionMacro.self,
        AddBlockerMacro.self,
        OptionSetMacro.self,
        MetaEnumMacro.self,
        CustomCodableMacro.self,
        CodableKeyMacro.self,
        DictionaryStorageMacro.self,
        AddAsyncInterfaceMacro.self,
        AddAsyncInterfaceAllMembersMacro.self,
        AddAsyncImplementationMacro.self,
        AddAsyncImplementationAllMembersMacro.self,
    ]
}
