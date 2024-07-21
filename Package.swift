// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BonMot",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "BonMot",
            targets: ["BonMot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "BonMot",
            dependencies: [],
            path: "Sources",
            exclude: []
        ),
        .testTarget(
            name: "BonMotTests",
            dependencies: [
                "BonMot",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Tests",
            exclude: [
                "__Snapshots__",
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
