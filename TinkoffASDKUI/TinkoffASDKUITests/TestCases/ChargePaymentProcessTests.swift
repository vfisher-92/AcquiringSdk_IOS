//
//  ChargePaymentProcessTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class ChargePaymentProcessTests: XCTestCase {

    // MARK: - func start() when paymentFlow == .full

    func test_Start_when_paymentFlow_full_InitPayment_failure() {

        // given

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentStubReturn = { passedArgs in
            passedArgs.completion(.failure(TestsError.basic))
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallCounter,
            1
        )

        // then

        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedCallCounter, 1)
    }

    func test_Start_when_paymentFlow_full_InitPayment_success_Charge_success() {

        let paymentStatus = PaymentStatus.authorized

        let getPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "2222",
            amount: 234,
            orderId: "32423423",
            status: paymentStatus
        )

        let initPayload = InitPayload(
            amount: 324,
            orderId: "324234",
            paymentId: "2222",
            status: paymentStatus
        )

        let chargePayload = ChargePayload(status: paymentStatus, paymentState: getPaymentStatePayload)

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentStubReturn = { passedArgs in
            passedArgs.completion(.success(initPayload))
            return EmptyCancellable()
        }

        dependencies.paymentsServiceMock.chargeStubReturn = { passedArgs in
            passedArgs.completion(.success(chargePayload))
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallCounter,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
    }

    func test_Start_when_paymentFlow_full_InitPayment_success_Charge_failure() {

        let paymentStatus = PaymentStatus.authorized

        let initPayload = InitPayload(
            amount: 324,
            orderId: "324234",
            paymentId: "2222",
            status: paymentStatus
        )

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentStubReturn = { passedArgs in
            passedArgs.completion(.success(initPayload))
            return EmptyCancellable()
        }

        dependencies.paymentsServiceMock.chargeStubReturn = { passedArgs in
            passedArgs.completion(.failure(TestsError.basic))
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallCounter,
            1
        )

        // then
        XCTAssertEqual(dependencies.paymentsServiceMock.chargeCallCounter, 1)
        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedCallCounter, 1)
    }

    // MARK: - func start() when paymentFlow == .finish

    func test_Start_paymentFlow_finish_Charge_success() {
        let dependencies = Self.makeDependencies(
            paymentFlow: .finish(paymentId: "23423", customerOptions: CustomerOptions(customerKey: "someKey", email: "some"))
        )

        let paymentState = GetPaymentStatePayload(
            paymentId: "324234",
            amount: 234,
            orderId: "23423",
            status: .authorized
        )

        let chargePayload = ChargePayload(status: .authorized, paymentState: paymentState)

        dependencies.paymentsServiceMock.chargeStubReturn = { passedArgs in
            passedArgs.completion(.success(chargePayload))
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishCallCounter,
            1
        )
    }

    func test_Start_paymentFlow_finish_Charge_failure() {
        let dependencies = Self.makeDependencies(
            paymentFlow: .finish(paymentId: "23423", customerOptions: CustomerOptions(customerKey: "someKey", email: "some"))
        )

        dependencies.paymentsServiceMock.chargeStubReturn = { passedArgs in
            passedArgs.completion(.failure(TestsError.basic))
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallCounter,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedCallCounter,
            1
        )
    }
}

extension ChargePaymentProcessTests {

    func start_when_paymentFlow_full(
        initPayloadResult: Result<InitPayload, Error>
    ) -> Dependencies {
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentStubReturn = { passedArgs in
            passedArgs.completion(initPayloadResult)
            return EmptyCancellable()
        }

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallCounter,
            1
        )

        return dependencies
    }
}

// MARK: - Dependencies

extension ChargePaymentProcessTests {

    struct Dependencies {
        let sut: ChargePaymentProcess
        let sutAsProtocol: PaymentProcess
        let paymentDelegateMock: MockPaymentProcessDelegate
        let paymentsServiceMock: MockAcquiringPaymentsService
        let paymentSource: PaymentSourceData
    }

    static func makeDependencies(paymentFlow: PaymentFlow) -> Dependencies {
        let paymentDelegateMock = MockPaymentProcessDelegate()
        let paymentsServiceMock = MockAcquiringPaymentsService()
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_parentPayment()

        let sut = ChargePaymentProcess(
            paymentsService: paymentsServiceMock,
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            delegate: paymentDelegateMock
        )

        return Dependencies(
            sut: sut,
            sutAsProtocol: sut,
            paymentDelegateMock: paymentDelegateMock,
            paymentsServiceMock: paymentsServiceMock,
            paymentSource: paymentSource
        )
    }
}
