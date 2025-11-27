import ProjectDescription

let project = Project(
    name: "FeatureCalendar",
    targets: [
        .target(
            name: "FeatureCalendar",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.featurecalendar",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
