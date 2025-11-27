import ProjectDescription

let project = Project(
    name: "Data",
    targets: [
        .target(
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.data",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "SupabaseClient", path: "../SupabaseClient"),
                .project(target: "SwiftDataClient", path: "../SwiftDataClient"),
                .project(target: "Shared", path: "../Shared"),
            ]
        )
    ]
)
