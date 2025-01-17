//
//
//  PaymentInitResponse.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

import Foundation

public struct PaymentInitResponse: ResponseOperation {
    private enum CodingKeys: CodingKey {
        case success
        case errorCode
        case errorMessage
        case errorDetails
        case terminalKey
        //
        case amount
        case orderId
        case paymentId
        case status

        var stringValue: String {
            switch self {
            case .success: return Constants.Keys.success
            case .errorCode: return Constants.Keys.errorCode
            case .errorMessage: return Constants.Keys.errorMessage
            case .errorDetails: return Constants.Keys.errorDetails
            case .terminalKey: return Constants.Keys.terminalKey
            case .amount: return Constants.Keys.amount
            case .orderId: return Constants.Keys.orderId
            case .paymentId: return Constants.Keys.paymentId
            case .status: return Constants.Keys.status
            }
        }
    }

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    //
    public var amount: Int64
    public var orderId: String
    public var paymentId: Int64
    public var status: PaymentStatus

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)

        amount = try container.decode(Int64.self, forKey: .amount)

        orderId = try container.decode(String.self, forKey: .orderId)

        if let stringValue = try? container.decode(String.self, forKey: .paymentId), let value = Int64(stringValue) {
            paymentId = value
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }

        if let statusValue = try? container.decode(String.self, forKey: .status) {
            status = PaymentStatus(rawValue: statusValue)
        } else {
            status = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        //
        try container.encode(amount, forKey: .amount)
        try container.encode(orderId, forKey: .orderId)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(terminalKey, forKey: .terminalKey)
    }
}
