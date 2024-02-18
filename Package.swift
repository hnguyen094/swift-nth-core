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
        .library(
            name: "NthComposable",
            targets: ["NthComposable"]),
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.7.0")
    ],
    targets: [
        .target(
            name: "NthCore"),
        .target(
            name: "NthComposable",
            dependencies: [
                .target(name: "NthCore"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "NthVision"),
    ]
)
