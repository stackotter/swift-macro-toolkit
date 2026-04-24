// swift-tools-version: 5.9

import CompilerPluginSupport
import Foundation
import PackageDescription

let env = ProcessInfo.processInfo.environment
let swiftSyntaxVersionOverride = env["MACROTOOLKIT_SWIFT_SYNTAX_VERSION_OVERRIDE"]

let swiftSyntaxURL = "https://github.com/swiftlang/swift-syntax"
let swiftSyntaxDependency: Package.Dependency
if let swiftSyntaxVersionOverride, let version = Version(swiftSyntaxVersionOverride) {
    swiftSyntaxDependency = .package(
        url: swiftSyntaxURL,
        from: version
    )
} else {
    // This is the default
    swiftSyntaxDependency = .package(
        url: swiftSyntaxURL,
        "600.0.0"..<"604.0.0"
    )
}

let package = Package(
    name: "swift-macro-toolkit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "MacroToolkit",
            targets: ["MacroToolkit"]
        )
    ],
    dependencies: [
        swiftSyntaxDependency,
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/SwiftPackageIndex/SPIManifest.git", from: "0.12.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.4.0"),
    ],
    targets: [
        // Implementations of macros tested by tests
        .macro(
            name: "MacroToolkitExamplePlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "MacroToolkit",
            ]
        ),

        // Declares macros used by tests
        .target(name: "MacroToolkitExample", dependencies: ["MacroToolkitExamplePlugin"]),

        .target(
            name: "MacroToolkit",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .testTarget(
            name: "MacroToolkitTests",
            dependencies: [
                "MacroToolkitExamplePlugin",
                "MacroToolkit",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
    ]
)
