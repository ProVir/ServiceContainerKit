// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceContainerKit",
    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(name: "ServiceContainerKit", targets: ["ServiceContainerKit"]),
        .library(name: "ServiceInjects", targets: ["ServiceInjects"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ServiceContainerKit",
            dependencies: [],
            path: "ServiceContainerKit/Sources",
            exclude: ["Info.plist"]),
        .target(
            name: "ServiceInjects",
            dependencies: ["ServiceContainerKit"],
            path: "ServiceInjects/Sources",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "ServiceContainerKitTests",
            dependencies: ["ServiceContainerKit"],
            path: "ServiceContainerKit/Tests",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "ServiceInjectsTests",
            dependencies: ["ServiceInjects"],
            path: "ServiceInjects/Tests",
            exclude: ["Info.plist"])
    ],
    swiftLanguageVersions: [.v5]
)
