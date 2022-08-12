// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CLTokenInputView",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "CLTokenInputView", targets: ["CLTokenInputView"])
    ],
    targets: [
        .target(
            name: "CLTokenInputView",
            path: "CLTokenInputView/CLTokenInputView",
            publicHeadersPath: "./"
        )
    ]
)
