//
//  YPPaymentSheetBuilder.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore
import YandexPaySDK

protocol IYPPaymentSheetBuilder {
    func build(with initData: PaymentInitData) -> YPPaymentSheet
}

final class YPPaymentSheetBuilder: IYPPaymentSheetBuilder {
    private let method: YandexPayMethod

    init(method: YandexPayMethod) {
        self.method = method
    }

    func build(with initData: PaymentInitData) -> YPPaymentSheet {
        let cardMethod = YPCardPaymentMethod(
            gateway: "Tinkoff",
            gatewayMerchantId: method.merchantId,
            allowedAuthMethods: [.panOnly],
            allowedCardNetworks: [.visa, .mastercard, .mir]
        )

        let order = YPOrder(id: initData.orderId, amount: "\(Double(initData.amount) / 100)")

        let paymentSheet = YPPaymentSheet(
            countryCode: .ru,
            currencyCode: .rub,
            order: order,
            paymentMethods: [.card(cardMethod)]
        )
        return paymentSheet
    }
}
