// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DragDropiOS",

    products: [
        .library(
            name: "DragDropiOS",
            targets: ["DragDropiOS"]),
    ],

    targets: [
        .target(
            name: "DragDropiOS",
            path: "DragDropiOS/Classes")
    ]
)