//
//  YandexPayFacade.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import YandexPaySDK

final class YandexPaySDKFacade {}

// MARK: - IYandexPaySDKInitializable

extension YandexPaySDKFacade: IYandexPaySDKInitializable {
    var isInitialized: Bool {
        YandexPaySDKApi.isInitialized
    }

    func initialize(configuration: YandexPaySDKConfiguration) throws {
        try YandexPaySDKApi.initialize(configuration: configuration)
    }
}

// MARK: - IYandexPaySDKButtonBuilder

extension YandexPaySDKFacade: IYandexPaySDKButtonBuilder {
    func createButton(
        configuration: YandexPaySDK.YandexPayButtonConfiguration,
        asyncDelegate: YandexPaySDK.YandexPayButtonAsyncDelegate
    ) -> YandexPaySDK.YandexPayButton {
        YandexPaySDKApi.instance.createButton(configuration: configuration, asyncDelegate: asyncDelegate)
    }
}

// MARK: - IApplicationEventsHandler

extension YandexPaySDKFacade: IApplicationEventsHandler {
    func applicationWillEnterForeground() {
        YandexPaySDKApi.instance.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive() {
        YandexPaySDKApi.instance.applicationDidBecomeActive()
    }

    func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) {
        YandexPaySDKApi.instance.applicationDidReceiveOpen(url, sourceApplication: sourceApplication)
    }

    func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) {
        YandexPaySDKApi.instance.applicationDidReceiveUserActivity(userActivity)
    }
}
