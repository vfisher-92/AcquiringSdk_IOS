//
//  ASDKYandexPayButtonFactory.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import YandexPaySDK

protocol IYandexPayButtonContainerControllerBuilder {
    func build(with delegate: IYandexPayControllerDelegate) -> IYandexPayController
}

protocol IYandexPayButtonContainerBuilder {
    func build(with configuration: YandexPayButtonContainerConfiguration) -> IYandexPayButtonContainer
}

final class YandexPayButtonContainerBuilder {
    private let buttonBuilder: IYandexPaySDKButtonBuilder
    private let controllerBuilder: IYandexPayButtonContainerControllerBuilder

    init(
        buttonBuilder: IYandexPaySDKButtonBuilder,
        controllerBuilder: IYandexPayButtonContainerControllerBuilder
    ) {
        self.buttonBuilder = buttonBuilder
        self.controllerBuilder = controllerBuilder
    }

    func build(
        with configuration: YandexPayButtonContainerConfiguration,
        delegate: IYandexPayButtonContainerDelegate
    ) -> IYandexPayButtonContainer {
        YandexPayButtonContainer(
            configuration: configuration,
            buttonBuilder: buttonBuilder,
            controllerBuilder: controllerBuilder,
            delegate: delegate
        )
    }
}
