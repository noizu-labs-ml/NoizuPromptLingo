// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TheRobotPaints",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "therobotpaints",
            targets: ["TheRobotPaints"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TheRobotPaints",
            dependencies: []
        ),
        .testTarget(
            name: "TheRobotPaintsTests",
            dependencies: ["TheRobotPaints"]
        )
    ]
)
