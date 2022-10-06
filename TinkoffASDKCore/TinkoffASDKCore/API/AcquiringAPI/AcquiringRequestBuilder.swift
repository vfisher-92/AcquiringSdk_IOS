//
//  AcquiringRequestBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 05.10.2022.
//

import Foundation

final class AcquiringRequestBuilder {
    private let terminalKey: String
    private let publicKey: SecKey
    private let baseURL: URL
    private let initParamsEnricher: IPaymentInitDataParamsEnricher
    private let cardDataFormatter: CardDataFormatter
    private let rsaEncryptor: RSAEncryptor

    init(
        terminalKey: String,
        publicKey: SecKey,
        baseURL: URL,
        initParamsEnricher: IPaymentInitDataParamsEnricher,
        cardDataFormatter: CardDataFormatter,
        rsaEncryptor: RSAEncryptor
    ) {
        self.terminalKey = terminalKey
        self.baseURL = baseURL
        self.publicKey = publicKey
        self.initParamsEnricher = initParamsEnricher
        self.cardDataFormatter = cardDataFormatter
        self.rsaEncryptor = rsaEncryptor
    }

    func initRequest(data: PaymentInitData) -> AcquiringRequest {
        let enrichedData = initParamsEnricher.enrich(data)
        return InitRequest(paymentInitData: enrichedData, baseURL: baseURL)
    }

    func finishAuthorize(data: FinishAuthorizeData) -> AcquiringRequest {
        FinishAuthorizeRequest(
            requestData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func check3DSVersion(data: Check3DSVersionData) -> AcquiringRequest {
        Check3DSVersionRequest(
            check3DSRequestData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func submit3DSAuthorizationV2(data: CresData) -> AcquiringRequest {
        ThreeDSV2AuthorizationRequest(data: data, baseURL: baseURL)
    }

    func getPaymentState(data: GetPaymentStateData) -> AcquiringRequest {
        GetPaymentStateRequest(data: data, baseURL: baseURL)
    }

    func charge(data: ChargeData) -> AcquiringRequest {
        ChargePaymentRequest(data: data, baseURL: baseURL)
    }

    func getCardList(data: GetCardListData) -> AcquiringRequest {
        GetCardListRequest(getCardListData: data, baseURL: baseURL)
    }

    func addCard(data: AddCardData) -> AcquiringRequest {
        AddCardRequest(initAddCardData: data, baseURL: baseURL)
    }

    func attachCard(data: AttachCardData) -> AcquiringRequest {
        AttachCardRequest(
            finishAddCardData: data,
            encryptor: rsaEncryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey,
            baseURL: baseURL
        )
    }

    func submitRandomAmount(data: SubmitRandomAmountData) -> AcquiringRequest {
        SubmitRandomAmountRequest(submitRandomAmountData: data, baseURL: baseURL)
    }

    func deactivateCard(data: DeactivateCardData) -> AcquiringRequest {
        DeactivateCardRequest(deactivateCardData: data, baseURL: baseURL)
    }

    func getQR(data: GetQRData) -> AcquiringRequest {
        GetQRRequest(data: data, baseURL: baseURL)
    }

    func getStaticQR(data: GetQRDataType) -> AcquiringRequest {
        GetStaticQRRequest(sourceType: data, baseURL: baseURL)
    }

    func getTinkoffPayStatus() -> AcquiringRequest {
        GetTinkoffPayStatusRequest(terminalKey: terminalKey, baseURL: baseURL)
    }

    func getTinkoffPayLink(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version
    ) -> AcquiringRequest {
        GetTinkoffLinkRequest(paymentId: paymentId, version: version, baseURL: baseURL)
    }
}
