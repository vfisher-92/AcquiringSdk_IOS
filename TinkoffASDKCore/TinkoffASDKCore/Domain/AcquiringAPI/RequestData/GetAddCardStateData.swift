//
//  GetAddCardStateData.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.02.2023.
//

import Foundation

public struct GetAddCardStateData: Encodable {
    /// Идентификатор запроса на привязку карты
    public let requestKey: String

    public init(requestKey: String) {
        self.requestKey = requestKey
    }
}
