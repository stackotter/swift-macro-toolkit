// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

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
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            exact: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-08-15-a"
        ),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/SwiftPackageIndex/SPIManifest.git", from: "0.12.0"),
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
                "MacroToolkitExample",
                "MacroToolkit",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
