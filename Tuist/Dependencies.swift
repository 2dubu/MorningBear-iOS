//
//  Dependencies.swift
//  Config
//
//  Created by 이영빈 on 2022/11/28.
//

import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    carthage: [],
    swiftPackageManager: [
        .remote(
            url: "https://github.com/Moya/Moya.git",
            requirement: .upToNextMajor(from: "15.0.0")
        ),
        .remote(
            url: "https://github.com/ReactiveX/RxSwift.git",
            requirement: .upToNextMajor(from: "6.5.0")
        )
    ],
    platforms: [.iOS]
)
