//
//  YandexPayButtonContainer.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 01.12.2022.
//

import UIKit
import YandexPaySDK

public protocol IYandexPayButtonContainer {
    var theme: YandexPayButtonTheme { get }
    func setLoaderVisible(_ visible: Bool, animated: Bool)
    func reloadPersonalizationData(completion: @escaping (Error?) -> Void)
    func setTheme(_ theme: YandexPayButtonTheme, animated: Bool)
}

final class YandexPayButtonContainer: UIView {
    private var configuration: YandexPayButtonContainerConfiguration
    private let innerButtonBuilder: IYandexPaySDKButtonBuilder
    private let innerButtonDelegate: YandexPayButtonAsyncDelegate

    private lazy var innerButton: YandexPayButton = innerButtonBuilder.createButton(
        configuration: configuration.mappedToYandexPaySDK,
        asyncDelegate: innerButtonDelegate
    )

    // MARK: Init

    init(
        configuration: YandexPayButtonContainerConfiguration,
        innerButtonBuilder: IYandexPaySDKButtonBuilder,
        innerButtonDelegate: YandexPayButtonAsyncDelegate
    ) {
        self.configuration = configuration
        self.innerButtonBuilder = innerButtonBuilder
        self.innerButtonDelegate = innerButtonDelegate
        super.init(frame: .zero)
        initialSetup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Setup

    private func initialSetup() {
        addSubview(innerButton)
        innerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerButton.topAnchor.constraint(equalTo: topAnchor),
            innerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let cornerRadius = configuration.cornerRadius {
            innerButton.layer.cornerRadius = cornerRadius
        }
    }
}

// MARK: - IYandexPayButtonContainer

extension YandexPayButtonContainer: IYandexPayButtonContainer {
    var theme: YandexPayButtonTheme {
        configuration.theme
    }

    func setLoaderVisible(_ visible: Bool, animated: Bool) {
        innerButton.setLoaderVisible(visible, animated: animated)
    }

    func reloadPersonalizationData(completion: @escaping (Error?) -> Void) {
        innerButton.reloadPersonalizationData(completion: completion)
    }

    func setTheme(_ theme: YandexPayButtonTheme, animated: Bool) {
        configuration = configuration.copyReplacing(theme: theme)
        innerButton.setTheme(configuration.theme.mappedToYandexPaySDK, animated: animated)
    }
}

// MARK: - YandexPayButtonContainerConfiguration + Utils

private extension YandexPayButtonContainerConfiguration {
    func copyReplacing(theme: YandexPayButtonTheme) -> YandexPayButtonContainerConfiguration {
        YandexPayButtonContainerConfiguration(theme: theme, cornerRadius: cornerRadius)
    }
}
