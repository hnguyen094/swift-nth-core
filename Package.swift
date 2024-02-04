// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-nth-core",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NthCore",
            targets: ["NthCore"]),
        .library(
            name: "NthComposable",
            targets: ["NthComposable"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NthCore"),
        .target(
            name: "NthComposable",
            dependencies: [
                "NthCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ])
    ]
)
