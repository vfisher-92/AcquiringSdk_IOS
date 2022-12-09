//
//  YandexPayButtonContainer.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 01.12.2022.
//

import TinkoffASDKCore
import UIKit
import YandexPaySDK

public protocol IYandexPayButtonContainer: UIView {
    var theme: YandexPayButtonTheme { get }
    func setLoaderVisible(_ visible: Bool, animated: Bool)
    func reloadPersonalizationData(completion: @escaping (Error?) -> Void)
    func setTheme(_ theme: YandexPayButtonTheme, animated: Bool)
}

final class YandexPayButtonContainer: UIView {
    // MARK: Dependencies

    private var configuration: YandexPayButtonContainerConfiguration
    private let buttonBuilder: IYandexPaySDKButtonBuilder
    private let controllerBuilder: IYandexPayButtonContainerControllerBuilder
    private weak var delegate: IYandexPayButtonContainerDelegate?

    // MARK: Lazy Dependencies

    private lazy var yandexPayButton: YandexPayButton = buttonBuilder.createButton(
        configuration: configuration.mappedToYandexPaySDK,
        asyncDelegate: self
    )

    private lazy var controller: IYandexPayController = controllerBuilder.build(with: self)

    // MARK: Init

    init(
        configuration: YandexPayButtonContainerConfiguration,
        buttonBuilder: IYandexPaySDKButtonBuilder,
        controllerBuilder: IYandexPayButtonContainerControllerBuilder,
        delegate: IYandexPayButtonContainerDelegate
    ) {
        self.configuration = configuration
        self.buttonBuilder = buttonBuilder
        self.controllerBuilder = controllerBuilder
        self.delegate = delegate
        super.init(frame: .zero)
        initialSetup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Setup

    private func initialSetup() {
        addSubview(yandexPayButton)
        yandexPayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yandexPayButton.topAnchor.constraint(equalTo: topAnchor),
            yandexPayButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            yandexPayButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            yandexPayButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let cornerRadius = configuration.cornerRadius {
            yandexPayButton.layer.cornerRadius = cornerRadius
        }
    }
}

// MARK: - IYandexPayButtonContainer

extension YandexPayButtonContainer: IYandexPayButtonContainer {
    var theme: YandexPayButtonTheme {
        configuration.theme
    }

    func setLoaderVisible(_ visible: Bool, animated: Bool) {
        yandexPayButton.setLoaderVisible(visible, animated: animated)
    }

    func reloadPersonalizationData(completion: @escaping (Error?) -> Void) {
        yandexPayButton.reloadPersonalizationData(completion: completion)
    }

    func setTheme(_ theme: YandexPayButtonTheme, animated: Bool) {
        configuration = configuration.copyReplacing(theme: theme)
        yandexPayButton.setTheme(theme.mappedToYandexPaySDK, animated: animated)
    }
}

// MARK: - YandexPayButtonAsyncDelegate

extension YandexPayButtonContainer: YandexPayButtonAsyncDelegate {
    func yandexPayButtonDidRequestViewControllerForPresentation(_ button: YandexPaySDK.YandexPayButton) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayButtonDidRequestPaymentSheet(
        _ button: YandexPaySDK.YandexPayButton,
        completion: @escaping (YandexPaySDK.YPPaymentSheet?) -> Void
    ) {
        controller.requestPaymentSheet(completion: completion)
    }

    func yandexPayButton(
        _ button: YandexPaySDK.YandexPayButton,
        didCompletePaymentWithResult result: YandexPaySDK.YPPaymentResult
    ) {
        controller.handlePaymentResult(result)
    }
}

// MARK: - IYandexPayButtonContainerControllerDelegate

extension YandexPayButtonContainer: IYandexPayControllerDelegate {
    func yandexPayControllerDidRequestViewControllerForPresentation(
        _ controller: IYandexPayController
    ) -> UIViewController? {
        delegate?.yandexPayButtonContainerDidRequestViewControllerForPresentation(self)
    }

    func yandexPayController(
        _ controller: IYandexPayController,
        didRequestPaymentData completion: @escaping (TinkoffASDKCore.PaymentInitData?) -> Void
    ) {
        delegate?.yandexPayButtonContainerDidRequestInitData(self, completion: completion)
    }

    func yandexPayController(
        _ controller: YandexPayController,
        didCompleteWithResult result: YandexPayButtonContainerResult
    ) {
        delegate?.yandexPayButtonContainer(self, didCompletePaymentWithResult: result)
    }
}

// MARK: - YandexPayButtonContainerConfiguration + Utils

private extension YandexPayButtonContainerConfiguration {
    func copyReplacing(theme: YandexPayButtonTheme) -> YandexPayButtonContainerConfiguration {
        YandexPayButtonContainerConfiguration(theme: theme, cornerRadius: cornerRadius)
    }
}
