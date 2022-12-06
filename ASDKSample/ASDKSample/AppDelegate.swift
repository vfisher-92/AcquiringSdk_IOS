//
//  AppDelegate.swift
//  ASDKSample
//
//  Copyright (c) 2020 Tinkoff Bank
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

import TinkoffASDKYandexPay
import UIKit
import YandexPaySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let merchant = YandexPaySDKMerchant(
            id: "bbb9c171-2fab-45e6-b1f8-6212980aa9bb",
            name: "Calooking",
            url: "http://calooking.com"
        )

        let configuration = YandexPaySDKConfiguration(
            environment: .sandbox,
            merchant: merchant,
            locale: .ru
        )

        do {
            try YandexPaySDKApi.initialize(configuration: configuration)
        } catch {
            assertionFailure("YandexPay initialization failed with error: \(error)")
        }

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        YandexPaySDKApi.instance.applicationDidReceiveUserActivity(userActivity)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        YandexPaySDKApi.instance.applicationDidReceiveOpen(url, sourceApplication: options[.sourceApplication] as? String)
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        YandexPaySDKApi.instance.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        YandexPaySDKApi.instance.applicationDidBecomeActive()
    }
}
