//
//  TerminalPayMethodsLoader.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore

protocol ITerminalPayMethodsLoader {
    func getTerminalPayMethods(completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void)
}

final class TerminalPayMethodsLoader: ITerminalPayMethodsLoader {
    private let coreSDK: AcquiringSdk

    init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }

    func getTerminalPayMethods(completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void) {
        coreSDK.getTerminalPayMethods(completion: completion)
    }
}
