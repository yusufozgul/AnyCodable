// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnyCodable",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AnyCodable",
            targets: ["AnyCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AnyCodable",
            dependencies: []),
        .testTarget(
            name: "AnyCodableTests",
            dependencies: ["AnyCodable"]),
    ]
)
