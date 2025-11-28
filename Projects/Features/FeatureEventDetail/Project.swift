import ProjectDescription

let project = Project(
    name: "FeatureEventDetail",
    targets: [
        .target(
            name: "FeatureEventDetail",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featureeventdetail",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core"),
                .project(target: "DSKit", path: "../../DSKit"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
