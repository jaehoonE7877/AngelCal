import ProjectDescription

let project = Project(
    name: "SupabaseClient",
    targets: [
        .target(
            name: "SupabaseClient",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.supabaseclient",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Shared", path: "../Shared"),
                .external(name: "Supabase"),
            ]
        )
    ]
)
