//
//  CardsService.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 14.02.2023.
//

public protocol ICardsService {
    func addCard(cardData: CardData, multiCompletion: @escaping CardsServiceAddCardCompletion)
}

public enum CardServiceAddCardCompletionType {
    case cardAdded(PaymentCard)
    case checked3DSVersion(Check3DSVersionPayload)
    case cardAttached(AttachCardPayload, addCardContinue: CardsServiceCardAttachedAddCardContinueCompletion)
}

public typealias CardsServiceCardAttachedAddCardContinueCompletion = (Result<Void, Error>) -> Void
public typealias CardsServiceAddCardCompletion = (Result<CardServiceAddCardCompletionType, Error>) -> Void

public final class CardsService: ICardsService {

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk

    // MARK: Properties

    public let customerKey: String

    // MARK: Initialization

    public init(coreSDK: AcquiringSdk, customerKey: String) {
        self.coreSDK = coreSDK
        self.customerKey = customerKey
    }
}

// MARK: - ICardsService

public extension CardsService {
    func addCard(cardData: CardData, multiCompletion: @escaping CardsServiceAddCardCompletion) {
        let addCardData = AddCardData(with: cardData.checkType, customerKey: customerKey)
        coreSDK.addCard(data: addCardData, completion: { [weak self] result in
            switch result {
            case let .success(payload):
                self?.check3DSVersionIfNeededAndAttachCard(
                    cardData: cardData,
                    addCardPayload: payload,
                    multiCompletion: multiCompletion
                )
            case let .failure(error):
                multiCompletion(.failure(error))
            }
        })
    }
}

// MARK: - Private

extension CardsService {
    private func check3DSVersionIfNeededAndAttachCard(
        cardData: CardData,
        addCardPayload: AddCardPayload,
        multiCompletion: @escaping CardsServiceAddCardCompletion
    ) {
        switch cardData.checkType {
        case .check3DS, .hold3DS:
            guard let paymentId = addCardPayload.paymentId else {
                return multiCompletion(.failure(AddCardError.missingPaymentId))
            }

            let paymentSource = PaymentSourceData.cardNumber(number: cardData.number, expDate: cardData.expDate, cvv: cardData.cvc)
            let check3DSVersionData = Check3DSVersionData(paymentId: paymentId, paymentSource: paymentSource)

            coreSDK.check3DSVersion(data: check3DSVersionData) { result in
                switch result {
                case let .success(payload):
                    multiCompletion(.success(.checked3DSVersion(payload)))

                    self.attachCard(
                        cardData: cardData,
                        addCardPayload: addCardPayload,
                        сheck3DSPayload: payload,
                        multiCompletion: multiCompletion
                    )
                case let .failure(error):
                    multiCompletion(.failure(error))
                }
            }
        case .no, .hold:
            attachCard(cardData: cardData, addCardPayload: addCardPayload, multiCompletion: multiCompletion)
        }
    }

    private func attachCard(
        cardData: CardData,
        addCardPayload: AddCardPayload,
        сheck3DSPayload: Check3DSVersionPayload? = nil,
        multiCompletion: @escaping CardsServiceAddCardCompletion
    ) {
        let needDeviceData = сheck3DSPayload?.tdsServerTransID != nil && сheck3DSPayload?.threeDSMethodURL != nil
        let deviceData = needDeviceData ? coreSDK.threeDSDeviceInfoProvider().deviceInfo : nil

        let attachData = AttachCardData(
            cardNumber: cardData.number,
            expDate: cardData.expDate,
            cvv: cardData.cvc,
            requestKey: addCardPayload.requestKey,
            deviceData: deviceData
        )

        coreSDK.attachCard(data: attachData) { [weak self] result in
            switch result {
            case let .success(attachPayload):
                self?.submit3DSAuthorization(
                    cardData: cardData,
                    attachPayload: attachPayload,
                    multiCompletion: multiCompletion
                )
            case let .failure(error):
                multiCompletion(.failure(error))
            }
        }
    }

    private func submit3DSAuthorization(
        cardData: CardData,
        attachPayload: AttachCardPayload,
        multiCompletion: @escaping CardsServiceAddCardCompletion
    ) {
        let addCardContinueCompletion: CardsServiceCardAttachedAddCardContinueCompletion = { result in
            switch result {
            case .success:
                self.getAddedCardState(cardData: cardData, attachPayload: attachPayload, multiCompletion: multiCompletion)
            case let .failure(error):
                multiCompletion(.failure(error))
            }
        }

        multiCompletion(.success(.cardAttached(attachPayload, addCardContinue: addCardContinueCompletion)))
    }

    private func getAddedCardState(
        cardData: CardData,
        attachPayload: AttachCardPayload,
        multiCompletion: @escaping CardsServiceAddCardCompletion
    ) {
        let getAddCardStateData = GetAddCardStateData(requestKey: attachPayload.requestKey)
        coreSDK.getAddCardState(data: getAddCardStateData) { result in
            switch result {
            case let .success(payload):
                let paymentCard = PaymentCard(
                    pan: cardData.number,
                    cardId: attachPayload.cardId,
                    status: payload.status,
                    parentPaymentId: nil,
                    expDate: cardData.expDate
                )

                multiCompletion(.success(.cardAdded(paymentCard)))
            case let .failure(error):
                multiCompletion(.failure(error))
            }
        }
    }
}

public struct CardData {
    // MARK: Properties

    public let number: String
    public let expDate: String
    public let cvc: String
    public let checkType: PaymentCardCheckType

    // MARK: Initialization

    public init(number: String, expDate: String, cvc: String, checkType: PaymentCardCheckType = .no) {
        self.number = number
        self.expDate = expDate
        self.cvc = cvc
        self.checkType = checkType
    }
}

private enum AddCardError: Error, LocalizedError {
    case missingPaymentId

    var errorDescription: String? {
        switch self {
        case .missingPaymentId:
            return "`paymentId` is required in the `AddCard` response when `checkType` is `3DS`, `3DSHOLD` or `HOLD`"
        }
    }
}
