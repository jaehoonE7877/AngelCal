import ProjectDescription

let project = Project(
    name: "DSKit",
    targets: [
        .target(
            name: "DSKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.angelcal.dskit",
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
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            dependencies: []
        )
    ]
)
