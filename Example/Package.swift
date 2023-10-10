// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "macro-toolkit-example",
    products: [
        .library(
          name: "Example",
          targets: ["Example"]
        ),
    ],
    dependencies: [
        // For basic functionality you can just depend on `swift-macro-toolkit`
        // `swift-syntax` will be added as nested dependency. "SwiftSyntax", "SwiftDiagnostics",
        // and "SwiftCompilerPlugin" targets will be importable
        .package("../"),

        // However `swift-syntax` is needed for testing
        // You may consider using https://github.com/pointfreeco/swift-macro-testing instead
        .package(
          url: "https://github.com/apple/swift-syntax.git",
          exact: "509.0.0"
        ),
    ],
    targets: [
        // Declares macros used by `swift-macro-toolkit` tests
        .target(
          name: "MacroToolkitExample",
          dependencies: ["MacroToolkitExamplePlugin"]
        ),

        // Implementations of macros tested by `swift-macro-toolkit` tests
        .macro(
            name: "MacroToolkitExamplePlugin",
            dependencies: [
                .product(name: "MacroToolkit", package: "swift-macro-toolkit")
            ]
        ),

        .testTarget(
            name: "MacroToolkitTests",
            dependencies: [
                "MacroToolkitExample",
                .product(name: "MacroToolkit", package: "swift-macro-toolkit")
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
