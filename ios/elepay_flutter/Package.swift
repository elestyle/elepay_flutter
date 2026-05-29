// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "elepay_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "elepay-flutter", targets: ["elepay_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/elestyle/elepay-ios-sdk", exact: "5.0.5")
    ],
    targets: [
        .target(
            name: "elepay_flutter",
            dependencies: [
                .product(name: "ElepaySDK", package: "elepay-ios-sdk"),
                .product(name: "ElepayCheckoutPlugin", package: "elepay-ios-sdk"),
            ]
        )
    ]
)
