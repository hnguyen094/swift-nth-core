// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-nth-core",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "NthCore",
            targets: ["NthCore"]
        ),
        .library(
            name: "NthComposableContacts",
            targets: ["NthComposableContacts"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.17.0"
        )
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
        ),
        .target(
            name: "NthComposableContacts",
            dependencies: [
                .target(name: "NthCommon"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources/composable-contacts"
        )
    ]
)
