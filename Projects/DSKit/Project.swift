import ProjectDescription

let project = Project(
    name: "DSKit",
    targets: [
        .target(
            name: "DSKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jaehoon.angelcal.dskit",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UIAppFonts": [
                        "Pretendard/Pretendard-Thin.otf",
                        "Pretendard/Pretendard-ExtraLight.otf",
                        "Pretendard/Pretendard-Light.otf",
                        "Pretendard/Pretendard-Regular.otf",
                        "Pretendard/Pretendard-Medium.otf",
                        "Pretendard/Pretendard-SemiBold.otf",
                        "Pretendard/Pretendard-Bold.otf",
                        "Pretendard/Pretendard-ExtraBold.otf",
                        "Pretendard/Pretendard-Black.otf",
                    ],
                ]
            ),
            sources: [
                "Sources/**",
                "Derived/Sources/**",
            ],
            resources: [
                "Resources/**",
            ],
            dependencies: []
        )
    ]
)
