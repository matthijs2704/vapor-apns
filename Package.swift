import PackageDescription

let package = Package(
    name: "VaporAPNS",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/boostcode/CCurl.git", majorVersion: 0, minor: 2),
    ]
)
