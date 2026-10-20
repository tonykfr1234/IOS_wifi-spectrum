// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WifiSpectrumCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "WifiSpectrumCore", targets: ["WifiSpectrumCore"])],
    targets: [
        .target(name: "WifiSpectrumCore", resources: [.copy("Resources/oui.tsv")]),
        .testTarget(name: "WifiSpectrumCoreTests", dependencies: ["WifiSpectrumCore"]),
    ]
)
