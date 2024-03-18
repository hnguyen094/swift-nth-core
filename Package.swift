// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-nth-core",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "NthCore",
            targets: ["NthCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "NthCore",
            dependencies: [
                .target(name: "NthCommon"),
                .target(name: "NthVisionOS", condition: .when(platforms: [.visionOS])),
                .target(name: "NthComposable")
            ],
            path: "Sources/core"
        ),
        .target(
            name: "NthCommon",
            path: "Sources/common"
        ),
        .target(
            name: "NthVisionOS",
            dependencies: [
                .target(name: "NthCommon")
            ],
            path: "Sources/visionos"
        ),
        .target(
            name: "NthComposable",
            dependencies: [
                .target(name: "NthCommon"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/composable"
        )
    ]
)
