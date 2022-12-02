//
//  YandexPayButtonConfiguration.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 01.12.2022.
//

import Foundation
import YandexPaySDK

/// Цвет кнопки `YandexPay`
public enum YandexPayButtonAppearance {
    /// Светлый цвет для темного фона
    case light
    /// Темный цвет для светлого фона
    case dark
}

/// Тема для кнопки `YandexPay`
public struct YandexPayButtonTheme {
    /// Цвет кнопки `YandexPay`
    public let appearance: YandexPayButtonAppearance
    /// Автоматически обновлять цвет при изменении темы
    public let dynamic: Bool

    /// Создание новой темы для кнопки `YandexPay`
    /// - Parameters:
    ///   - appearance: Цвет кнопки `YandexPay`
    ///   - dynamic: Автоматически обновлять цвет при изменении темы
    public init(appearance: YandexPayButtonAppearance, dynamic: Bool = true) {
        self.appearance = appearance
        self.dynamic = dynamic
    }
}

/// Конфигурация контейнера кнопки `YandexPay`
public struct YandexPayButtonContainerConfiguration {
    /// Тема для кнопки `YandexPay`
    public let theme: YandexPayButtonTheme
    /// Радиус скругления кнопки. При `nil` используется значение по умолчанию
    public let cornerRadius: CGFloat?

    /// Создание конфигурации контейнера кнопки `YandexPay`
    /// - Parameters:
    ///   - theme: Тема для кнопки `YandexPay`
    ///   - cornerRadius: Радиус скругления кнопки. При `nil` используется значение по умолчанию
    public init(theme: YandexPayButtonTheme, cornerRadius: CGFloat? = nil) {
        self.theme = theme
        self.cornerRadius = cornerRadius
    }
}

// MARK: - YandexPayButtonConfiguration + Mapping

extension YandexPayButtonContainerConfiguration {
    var mappedToYandexPaySDK: YandexPaySDK.YandexPayButtonConfiguration {
        YandexPaySDK.YandexPayButtonConfiguration(theme: theme.mappedToYandexPaySDK)
    }
}

// MARK: - YandexPayButtonConfiguration.Theme + Mapping

extension YandexPayButtonTheme {
    var mappedToYandexPaySDK: YandexPaySDK.YandexPayButtonTheme {
        if #available(iOS 13, *) {
            return YandexPaySDK.YandexPayButtonTheme(appearance: appearance.mappedToYandexPaySDK, dynamic: dynamic)
        } else {
            return YandexPaySDK.YandexPayButtonTheme(appearance: appearance.mappedToYandexPaySDK)
        }
    }
}

// MARK: - YandexPayButtonConfiguration.Appearance + Mapping

extension YandexPayButtonAppearance {
    var mappedToYandexPaySDK: YandexPaySDK.YandexPayButtonApperance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
