import PackageDescription

let package = Package(
    name: "Epoch",
    targets: [
        Target(name: "App", dependencies: [
            "EpochAuth",
            "Meetapp"
        ])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources"
    ]
)

