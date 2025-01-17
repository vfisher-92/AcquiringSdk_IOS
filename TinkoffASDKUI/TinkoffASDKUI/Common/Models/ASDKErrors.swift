//
//  ASDKErrors.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 06.02.2023.
//

import Foundation

public struct ASDKError: Error {
    public enum Code: Int {
        case unknown = 123_000
        case timeout = 123_001
        case rejected = 123_002
    }

    public let code: Code
    public let underlyingError: Error?

    public init(code: Code, underlyingError: Error? = nil) {
        self.code = code
        self.underlyingError = underlyingError
    }
}

// MARK: - LocalizedError

extension ASDKError: LocalizedError {
    public var errorDescription: String? {
        let codeDescription: String = {
            switch code {
            case .unknown:
                return "Unknown error"
            case .timeout:
                return "Time or retries count is over"
            case .rejected:
                return "Payment failed"
            }
        }()

        let underlyingErrorDescription = underlyingError.map {
            "Underlying error: \($0.localizedDescription)"
        }

        let fullDescription = [codeDescription, underlyingErrorDescription]
            .compactMap { $0 }
            .joined(separator: "; ")

        return fullDescription
    }
}

// MARK: - CustomNSError

extension ASDKError: CustomNSError {
    public var errorCode: Int { code.rawValue }

    public var errorUserInfo: [String: Any] {
        let userInfo: [String: Any?] = [
            NSLocalizedDescriptionKey: errorDescription,
            NSUnderlyingErrorKey: underlyingError,
        ]

        return userInfo.compactMapValues { $0 }
    }
}
