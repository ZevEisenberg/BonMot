// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_13)],
    dependencies: [
      .package(url: "https://github.com/cpisciotta/xcbeautify", from: "2.4.1"),
    ],
    targets: [
      .target(name: "BuildTools", path: "")
    ]
)
