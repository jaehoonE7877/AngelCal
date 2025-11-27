// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific packages
        productTypes: [
            "ComposableArchitecture": .framework,
            "Supabase": .framework,
            // Supabase transitive products
            "Auth": .framework,
            "Clocks": .framework,
            "ConcurrencyExtras": .framework,
            "Crypto": .framework,
            "Functions": .framework,
            "HTTPTypes": .framework,
            "Helpers": .framework,
            "IssueReporting": .framework,
            "IssueReportingPackageSupport": .framework,
            "PostgREST": .framework,
            "Realtime": .framework,
            "Storage": .framework,
            // TCA helper
            "XCTestDynamicOverlay": .framework,
        ]
    )
#endif

let package = Package(
    name: "AngelCal",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    ]
)
