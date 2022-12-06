//
//  YandexPayPaymentProcess.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 05.12.2022.
//

import Foundation
import TinkoffASDKCore

protocol IYandexPayPaymentProcess {
    func startASDKPayment(with paymentToken: String)
}

enum YandexPayPaymentProcessResult {
    case succeded
    case failed(Error)
    case cancelled
}

protocol IYandexPayPaymentProcessDelegate: AnyObject {
    func yandexPayPaymentProcess(_ process: IYandexPayPaymentProcess, didCompleteWith result: YandexPayPaymentProcessResult)
    func yandexPayPaymentProcessDidRequestViewControllerForPresentation(_ process: IYandexPayPaymentProcess) -> UIViewController?
}

protocol IYandexPayProcessBuilder {
    func build(with initData: PaymentInitData) -> IYandexPayPaymentProcess
}

final class YandexPayPaymentProcess: IYandexPayPaymentProcess {
    private let paymentData: PaymentInitData
    private weak var delegate: IYandexPayPaymentProcessDelegate?

    init(paymentData: PaymentInitData, delegate: IYandexPayPaymentProcessDelegate) {
        self.paymentData = paymentData
        self.delegate = delegate
    }

    func startASDKPayment(with paymentToken: String) {}
}
