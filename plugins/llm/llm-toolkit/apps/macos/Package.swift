// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LLMToolkit",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "LLMToolkitKit", targets: ["LLMToolkitKit"]),
        .executable(name: "LLMToolkit", targets: ["LLMToolkit"]),
    ],
    targets: [
        .target(
            name: "LLMToolkitKit",
            path: "Sources/LLMToolkitKit"
        ),
        .executableTarget(
            name: "LLMToolkit",
            dependencies: ["LLMToolkitKit"],
            path: "Sources/LLMToolkit",
            resources: [
                .process("Resources"),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("WebKit"),
            ]
        ),
        .testTarget(
            name: "LLMToolkitTests",
            dependencies: ["LLMToolkitKit"],
            path: "Tests/LLMToolkitTests"
        ),
    ]
)
