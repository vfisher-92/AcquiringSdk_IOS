//
//  GetAddCardStatePayload.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.02.2023.
//

import Foundation

/// Данные, полученные в методе `GetAddCardState`
public struct GetAddCardStatePayload: Equatable {
    public let terminalKey: String
    public let requestKey: String
    public let status: PaymentCardStatus
    public let success: Bool
    public let errorCode: Int?
    public let customerKey: String?
    public let cardId: String?
    public let rebillId: String?
    public let errorMessage: String?
    public let errorDetails: String?
}

// MARK: - GetAddCardStatePayload + Decodable

extension GetAddCardStatePayload: Decodable {
    private enum CodingKeys: CodingKey {
        case terminalKey
        case requestKey
        case status
        case success
        case errorCode
        case customerKey
        case cardId
        case rebillId
        case errorMessage
        case errorDetails

        var stringValue: String {
            switch self {
            case .terminalKey: return Constants.Keys.terminalKey
            case .requestKey: return Constants.Keys.requestKey
            case .status: return Constants.Keys.status
            case .success: return Constants.Keys.success
            case .errorCode: return Constants.Keys.errorCode
            case .customerKey: return Constants.Keys.customerKey
            case .cardId: return Constants.Keys.cardId
            case .rebillId: return Constants.Keys.rebillId
            case .errorMessage: return Constants.Keys.errorMessage
            case .errorDetails: return Constants.Keys.errorDetails
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        terminalKey = try container.decode(String.self, forKey: .terminalKey)
        requestKey = try container.decode(String.self, forKey: .requestKey)
        let statusRawValue = try container.decode(String.self, forKey: .status)
        status = PaymentCardStatus(rawValue: statusRawValue)
        success = try container.decode(Bool.self, forKey: .success)

        errorCode = try? Int(container.decode(String.self, forKey: .errorCode))
        customerKey = try? container.decode(String.self, forKey: .customerKey)
        cardId = try? container.decode(String.self, forKey: .cardId)
        rebillId = try? container.decode(String.self, forKey: .rebillId)
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
    }
}
