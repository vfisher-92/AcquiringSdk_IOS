//
//  YandexPayPaymentActivityPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayPaymentActivityPresenter {
    weak var view: IPaymentActivityViewInput?
}

// MARK: - IPaymentActivityViewOutput

extension YandexPayPaymentActivityPresenter: IPaymentActivityViewOutput {
    func viewDidLoad() {
        view?.update(with: .processing, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.view?.update(with: .paid, animated: true)
        }
    }

    func primaryButtonTapped() {
        view?.close()
    }

    func viewWasClosed() {
        print("")
    }
}

// MARK: - PaymentControllerDelegate

extension YandexPayPaymentActivityPresenter: PaymentControllerDelegate {
    func paymentController(
        _ controller: PaymentController,
        didFinishPayment: PaymentProcess,
        with state: TinkoffASDKCore.GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        view?.update(with: .paid, animated: true)
    }

    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        view?.close()
    }

    func paymentController(
        _ controller: PaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        view?.update(with: .failed, animated: true)
    }
}

// MARK: - PaymentActivityViewState + YandexPayPaymentActivity States

private extension PaymentActivityViewState {
    static var processing: PaymentActivityViewState {
        .processing(
            Processing(
                title: Loc.CommonSheet.Processing.title,
                description: Loc.CommonSheet.Processing.description
            )
        )
    }

    static var paid: PaymentActivityViewState {
        .processed(
            Processed(
                image: Asset.TuiIcMedium.checkCirclePositive.image,
                title: Loc.CommonSheet.Paid.title,
                primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
            )
        )
    }

    static var failed: PaymentActivityViewState {
        .processed(
            Processed(
                image: Asset.TuiIcMedium.crossCircle.image,
                title: Loc.YandexSheet.Failed.title,
                description: Loc.YandexSheet.Failed.description,
                primaryButtonTitle: Loc.YandexSheet.Failed.description
            )
        )
    }
}
