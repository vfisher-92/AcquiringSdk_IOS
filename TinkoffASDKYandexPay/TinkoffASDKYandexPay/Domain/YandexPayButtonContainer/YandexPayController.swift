//
//  YandexPayButtonContainerPresenter.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore
import YandexPaySDK

protocol IYandexPayControllerDelegate: AnyObject {
    func yandexPayControllerDidRequestViewControllerForPresentation(
        _ controller: IYandexPayController
    ) -> UIViewController?

    func yandexPayController(
        _ controller: IYandexPayController,
        didRequestPaymentData paymentData: @escaping (PaymentInitData?) -> Void
    )

    func yandexPayController(
        _ controller: YandexPayController,
        didCompleteWithResult result: YandexPayButtonContainerResult
    )
}

protocol IYandexPayController {
    func requestViewControllerForPresentation() -> UIViewController?
    func requestPaymentSheet(completion: @escaping (YandexPaySDK.YPPaymentSheet?) -> Void)
    func handlePaymentResult(_ result: YandexPaySDK.YPPaymentResult)
}

final class YandexPayController {
    // MARK: State Model

    enum State {
        case idle
        case yandexSideProcessing
        case acquiringSideProcessing
    }

    // MARK: Error Model

    enum Error: Swift.Error {
        case inconsistentState
        case unknown
    }

    // MARK: Dependencies

    private let paymentSheetBuilder: IYPPaymentSheetBuilder
    private weak var delegate: IYandexPayControllerDelegate?

    // MARK: State

    private var state: State = .idle

    // MARK: Init

    init(
        paymentSheetBuilder: IYPPaymentSheetBuilder,
        delegate: IYandexPayControllerDelegate
    ) {
        self.paymentSheetBuilder = paymentSheetBuilder
        self.delegate = delegate
    }

    private func cleanUp() {}
}

// MARK: - IYandexPayButtonContainerPresenterInput

extension YandexPayController: IYandexPayController {
    func requestViewControllerForPresentation() -> UIViewController? {
        return delegate?.yandexPayControllerDidRequestViewControllerForPresentation(self)
    }

    func requestPaymentSheet(completion: @escaping (YPPaymentSheet?) -> Void) {
        delegate?.yandexPayController(self) { [weak self] paymentData in
            guard let self = self else { return }

            guard let paymentData = paymentData else {
                return completion(nil)
            }

            let paymentSheet = self.paymentSheetBuilder.build(with: paymentData)
//            let process = self.processBuilder.build(with: paymentData)

            DispatchQueue.performOnMain {
//                self.paymentProcess = process
                completion(paymentSheet)
            }
        }
    }

    func handlePaymentResult(_ result: YPPaymentResult) {
        switch result {
        case let .succeeded(paymentInfo):
//            guard let paymentProcess = paymentProcess else {
//                delegate?.yandexPayController(self, didCompleteWithResult: .failed(.acquiringFlowError(.unknown(Error.inconsistentState))))
//                return
//            }
//            paymentProcess.startASDKPayment(with: paymentInfo.paymentToken)
            break
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
