import PackageDescription

let package = Package(
    name: "VaporAPNS",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/vapor/json.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/clibressl.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/console.git", majorVersion: 2),
        .Package(url: "https://github.com/matthijs2704/SwiftString.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/boostcode/CCurl.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/vapor/jwt.git", majorVersion: 2)
    ],
    exclude: ["Images"]
)
