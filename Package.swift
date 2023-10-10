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
        ),
        .library(
            name: "DiagnosticBuilder",
            targets: ["DiagnosticBuilder"]
        ),
        .library(
            name: "MacroToolkitTypes",
            targets: ["MacroToolkitTypes"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            exact: "509.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.3.0"
        ),
        .package(
            url: "https://github.com/SwiftPackageIndex/SPIManifest.git",
            .upToNextMinor(from: "0.12.0")
        ),
    ],
    targets: [
        .target(
            name: "MacroToolkit",
            dependencies: [
                .target(name: "DiagnosticBuilder"),
                .target(name: "MacroToolkitTypes")
            ]
        ),

        .target(
            name: "DiagnosticBuilder",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "MacroToolkitTypes",
            dependencies: [
                .target(name: "DiagnosticBuilder"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        )
    ]
)
