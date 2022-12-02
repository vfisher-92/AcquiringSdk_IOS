//
//  IYandexPaySDKButtonBuilder.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 02.12.2022.
//

import YandexPaySDK

protocol IYandexPaySDKButtonBuilder {
    func createButton(
        configuration: YandexPaySDK.YandexPayButtonConfiguration,
        asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate
    ) -> YandexPaySDK.YandexPayButton
}
