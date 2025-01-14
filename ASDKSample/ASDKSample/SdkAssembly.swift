//
//
//  SdkAssembly.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import TinkoffASDKUI

struct SdkAssembly {
    static func assembleUISDK(
        credential: SdkCredentials,
        style: Style = DefaultStyle()
    ) throws -> AcquiringUISDK {
        try AcquiringUISDK(configuration: createConfiguration(credential: credential), style: style)
    }

    static func assembleCoreSDK(credential: SdkCredentials) throws -> AcquiringSdk {
        try AcquiringSdk(configuration: createConfiguration(credential: credential))
    }

    private static func createConfiguration(credential: SdkCredentials) -> AcquiringSdkConfiguration {
        let sdkCredential = AcquiringSdkCredential(
            terminalKey: credential.terminalKey,
            publicKey: credential.publicKey
        )

        let tokenProvider = SampleTokenProvider(password: credential.terminalPassword)
        let logger = AcquiringLoggerDefault()

        let acquiringSDKConfiguration = AcquiringSdkConfiguration(
            credential: sdkCredential,
            tokenProvider: tokenProvider
        )
        acquiringSDKConfiguration.logger = logger

        return acquiringSDKConfiguration
    }
}
