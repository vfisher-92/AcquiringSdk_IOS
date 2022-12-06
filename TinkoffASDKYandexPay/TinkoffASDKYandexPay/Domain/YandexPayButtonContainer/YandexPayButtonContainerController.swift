//
//  YandexPayButtonContainerPresenter.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore
import YandexPaySDK

protocol IYandexPayButtonContainerControllerDelegate: AnyObject {
    func yandexPayControllerDidRequestViewControllerForPresentation(
        _ controller: IYandexPayButtonContainerController
    ) -> UIViewController?

    func yandexPayController(
        _ controller: IYandexPayButtonContainerController,
        didRequestPaymentData paymentData: @escaping (PaymentInitData?) -> Void
    )

    func yandexPayController(
        _ controller: YandexPayButtonContainerController,
        didCompleteWithResult result: YandexPayButtonContainerResult
    )
}

protocol IYandexPayButtonContainerController {
    func requestViewControllerForPresentation() -> UIViewController?
    func requestPaymentSheet(completion: @escaping (YandexPaySDK.YPPaymentSheet?) -> Void)
    func handlePaymentResult(_ result: YandexPaySDK.YPPaymentResult)
}

final class YandexPayButtonContainerController {
    // MARK: State Model

    enum State {
        case idle
        case yandexFlowPresenting
        case acquiringFlowPresenting
    }

    // MARK: Error Model

    enum Error: Swift.Error {
        case inconsistentState
        case unknown
    }

    // MARK: Dependencies

    private let processBuilder: IYandexPayProcessBuilder
    private let paymentSheetBuilder: IYPPaymentSheetBuilder
    private weak var delegate: IYandexPayButtonContainerControllerDelegate?

    // MARK: State

    private var paymentProcess: IYandexPayPaymentProcess?

    // MARK: Init

    init(
        processBuilder: IYandexPayProcessBuilder,
        paymentSheetBuilder: IYPPaymentSheetBuilder,
        delegate: IYandexPayButtonContainerControllerDelegate
    ) {
        self.processBuilder = processBuilder
        self.paymentSheetBuilder = paymentSheetBuilder
        self.delegate = delegate
    }

    private func cleanUp() {
        paymentProcess = nil
    }
}

// MARK: - IYandexPayButtonContainerPresenterInput

extension YandexPayButtonContainerController: IYandexPayButtonContainerController {
    func requestViewControllerForPresentation() -> UIViewController? {
        return delegate?.yandexPayControllerDidRequestViewControllerForPresentation(self)
    }

    func requestPaymentSheet(completion: @escaping (YPPaymentSheet?) -> Void) {
        let paymentDataCompletion = { [weak self] (paymentData: PaymentInitData?) in
            guard let self = self else { return }

            guard let paymentData = paymentData else {
                return completion(nil)
            }

            let paymentSheet = self.paymentSheetBuilder.build(with: paymentData)
            let process = self.processBuilder.build(with: paymentData)
            self.paymentProcess = process

            completion(paymentSheet)
        }

        delegate?.yandexPayController(self, didRequestPaymentDataOnMainQueue: paymentDataCompletion)
    }

    func handlePaymentResult(_ result: YPPaymentResult) {
        switch result {
        case let .succeeded(paymentInfo):
            guard let paymentProcess = paymentProcess else {
                delegate?.yandexPayController(self, didCompleteWithResult: .failed(.acquiringFlowError(.unknown(Error.inconsistentState))))
                return
            }
            paymentProcess.startASDKPayment(with: paymentInfo.paymentToken)
        case .cancelled:
            delegate?.yandexPayController(self, didCompleteWithResult: .cancelled)
            cleanUp()
        case let .failed(error):
            delegate?.yandexPayController(self, didCompleteWithResult: .failed(.yandexPayFlowError(.from(error))))
            cleanUp()
        @unknown default:
            delegate?.yandexPayController(self, didCompleteWithResult: .failed(.yandexPayFlowError(.unknownError)))
            cleanUp()
        }
    }
}

// MARK: - IYandexPayProcessDelegate

extension YandexPayButtonContainerController: IYandexPayPaymentProcessDelegate {
    func yandexPayPaymentProcess(_ process: IYandexPayPaymentProcess, didCompleteWith result: YandexPayPaymentProcessResult) {
        delegate?.yandexPayController(self, didCompleteWithResult: result.mappedToContainerResult)
        cleanUp()
    }

    func yandexPayPaymentProcessDidRequestViewControllerForPresentation(_ process: IYandexPayPaymentProcess) -> UIViewController? {
        delegate?.yandexPayControllerDidRequestViewControllerForPresentation(self)
    }
}

// MARK: - IYandexPayButtonContainerControllerDelegate + Request Payment Data On Main Queue

private extension IYandexPayButtonContainerControllerDelegate {
    func yandexPayController(
        _ controller: IYandexPayButtonContainerController,
        didRequestPaymentDataOnMainQueue completion: @escaping (PaymentInitData?) -> Void
    ) {
        let onMainQueueCompletion = { (paymentData: PaymentInitData?) in
            performOnMain {
                completion(paymentData)
            }
        }

        yandexPayController(controller, didRequestPaymentData: onMainQueueCompletion)
    }
}

private func performOnMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

private extension YandexPayPaymentProcessResult {
    var mappedToContainerResult: YandexPayButtonContainerResult {
        switch self {
        case .succeded:
            return .succeeded
        case let .failed(error):
            return .failed(.acquiringFlowError(.unknown(error)))
        case .cancelled:
            return .cancelled
        }
    }
}
