// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CLTokenInputView",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CLTokenInputView",
            targets: ["CLTokenInputView"]),
    ],
    targets: [
        .target(
            name: "CLTokenInputView",
            exclude: ["Supporting/Info.plist"],
            resources: [
                .process("CLTokenInputView.bundle"),
                .process("Assets"),
                .process("Resources")
            ]
        )
    ]
)
