//
//  IApplicationEventsHandler.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 02.12.2022.
//

import Foundation

protocol IApplicationEventsHandler {
    func applicationWillEnterForeground()
    func applicationDidBecomeActive()
    func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?)
    func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity)
}
