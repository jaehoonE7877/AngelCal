import ProjectDescription

let project = Project(
    name: "FeatureMain",
    targets: [
        .target(
            name: "FeatureMain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.featuremain",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "FeatureCalendar", path: "../FeatureCalendar"),
                .project(target: "FeatureSearch", path: "../FeatureSearch"),
                .project(target: "FeatureSettings", path: "../FeatureSettings"),
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
