// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ControlCenterExtra",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ControlCenterExtra",
            targets: ["ControlCenterExtra"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", from: "1.0.5"),
        .package(url: "https://github.com/orchetect/SettingsAccess", from: "1.4.0"),
        .package(path: "../Walberg"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ControlCenterExtra",
            dependencies: [
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "SettingsAccess", package: "SettingsAccess"),
                .product(name: "Walberg", package: "Walberg"),
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "ControlCenterUtilityTests",
            dependencies: ["ControlCenterExtra"]),
    ]
)
