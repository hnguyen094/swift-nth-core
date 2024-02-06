// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-nth-core",
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
            name: "NthCore",
            dependencies: [
                .target(name: "NthVision", condition: .when(platforms: [.visionOS]))
            ]),
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
