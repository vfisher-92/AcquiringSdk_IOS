//
//  YandexPayButtonContainerDelegate.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore
import YandexPaySDK

public enum YandexPayButtonContainerError: Error {
    case yandexPayFlowError(YPPaymentFlowError)
    case acquiringFlowError(AcquiringPaymentFlowError)
}

public enum YPPaymentFlowError: Error {
    case authenticationProblem
    case unknownMerchantOrigin
    case unknownMerchant
    case unknownGateway
    case insecureMerchantOrigin
    case amountLimitExceeded
    case invalidAmount
    case invalidCountry
    case invalidCurrency
    case amountMismatch
    case unknownError
}

extension YPPaymentFlowError {
    static func from(_ error: YPPaymentError) -> YPPaymentFlowError {
        switch error {
        case .authenticationProblem:
            return .authenticationProblem
        case .unknownMerchantOrigin:
            return .unknownMerchantOrigin
        case .unknownMerchant:
            return .unknownMerchant
        case .unknownGateway:
            return .unknownGateway
        case .insecureMerchantOrigin:
            return .insecureMerchantOrigin
        case .amountLimitExceeded:
            return .amountLimitExceeded
        case .invalidAmount:
            return .invalidAmount
        case .invalidCountry:
            return .invalidCountry
        case .invalidCurrency:
            return .invalidCurrency
        case .amountMismatch:
            return .amountMismatch
        case .unknownError:
            return .unknownError
        @unknown default:
            return .unknownError
        }
    }
}

public enum AcquiringPaymentFlowError: Error {
    case unknown(Error)
}

/// Результат оплаты с помощью `YandexPay`
public enum YandexPayButtonContainerResult {
    /// Успешное завершение оплаты
    case succeeded
    /// Произошла ошибка на этапе оплаты
    case failed(YandexPayButtonContainerError)
    /// Оплата отменена пользователем
    case cancelled
}

public protocol IYandexPayButtonContainerDelegate: AnyObject {
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: YandexPayButtonContainerResult
    )

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController?

    func yandexPayButtonContainerDidRequestInitData(
        _ container: IYandexPayButtonContainer,
        completion: @escaping (PaymentInitData?) -> Void
    )
}
