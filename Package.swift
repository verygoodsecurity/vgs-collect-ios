// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "VGSFramework",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "VGSFramework", targets: ["VGSFramework"]),
    ],
    dependencies: [
//        .package(url: "https://url/of/another/package/named/Utility", from: "1.0.0"),
        .package(name: "SnapKit"),
        .package(name: "Alamofire")
    ],
    targets: [
        .target(name: "VGSFramework"),
        .testTarget(name: "FrameworkTests", dependencies: ["VGSFramework"]),
    ]
)
