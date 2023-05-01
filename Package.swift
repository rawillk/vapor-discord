// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "vapor-discord",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .library(name: "Discord", targets: ["Discord"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/rawillk/vapor-bots.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "Discord", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Bots", package: "vapor-bots")
        ]),
        .executableTarget(
            name: "DiscordBotServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "Discord")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://www.swift.org/server/guides/building.html#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        )
    ]
)
