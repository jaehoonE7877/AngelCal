import ProjectDescription

let project = Project(
    name: "FeatureCalendar",
    targets: [
        .target(
            name: "FeatureCalendar",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featurecalendar",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .project(target: "FeatureEventEdit", path: "../FeatureEventEdit"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
