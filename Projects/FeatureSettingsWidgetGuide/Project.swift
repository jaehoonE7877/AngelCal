import ProjectDescription

let project = Project(
    name: "FeatureSettingsWidgetGuide",
    targets: [
        .target(
            name: "FeatureSettingsWidgetGuide",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.featuresettingswidgetguide",
            deploymentTargets: .iOS("18.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
