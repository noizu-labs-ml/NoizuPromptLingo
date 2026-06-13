// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KopiGajj",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "KopiGajj",
            targets: ["KopiGajj"]
        )
    ],
    dependencies: [
        // Add external dependencies here when needed
    ],
    targets: [
        .executableTarget(
            name: "KopiGajj",
            dependencies: [],
            path: "Sources/KopiGajj",
            exclude: ["Rendering/Shaders"]  // Metal files — compiled by Xcode, not SPM
        ),
        .testTarget(
            name: "KopiGajjTests",
            dependencies: ["KopiGajj"],
            path: "Tests/KopiGajjTests"
        )
    ]
)