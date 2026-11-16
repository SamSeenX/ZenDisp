// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenDisp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ZenDisp", targets: ["ZenDisp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ZenDisp",
            dependencies: [],
            path: "Sources/ZenDisp",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("ScreenCaptureKit"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("IOKit"),
                .linkedFramework("Carbon")
            ]
        )
    ]
)
