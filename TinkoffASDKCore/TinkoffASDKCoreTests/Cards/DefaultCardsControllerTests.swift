//
//
//  DefaultCardsControllerTests.swift
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


@testable import TinkoffASDKCore
import XCTest

final class DefaultCardsControllerTests: XCTestCase {
    let mockCardsLoader = MockCardsLoader()
    
    override func setUp() {
        mockCardsLoader.loadCardsTimesCalled = 0
        mockCardsLoader.result = .success([])
        mockCardsLoader.timeout = 1.5
    }
    
    func testCardsControllerNotifyListenersWithTargetCustomerKeyWhenStartLoad() {
        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)
        
        let listener1 = MockCardsControllerListener()
        cardsController.addListener(listener1)
        
        let listener2 = MockCardsControllerListener()
        cardsController.addListener(listener2)
        
        cardsController.loadCards { _ in }
        
        XCTAssertTrue(listener1.cardsControllerDidStartLoadCardsWasCalled)
        XCTAssertTrue(listener2.cardsControllerDidStartLoadCardsWasCalled)
    }
    
    func testCardsControllerCallCardsLoaderOneTimeIfCalledLoadCardsTwoTimesInRow() {
        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)

        mockCardsLoader.timeout = 1.0

        let expectation = XCTestExpectation()
        
        cardsController.loadCards { _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cardsController.loadCards { result in
                XCTAssertEqual(self.mockCardsLoader.loadCardsTimesCalled, 1)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testCardsControllerNotifyAddedListenerIfLoadingInProgress() {
        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)
        cardsController.loadCards() { _ in }

        let listener1 = MockCardsControllerListener()
        listener1.customerKey = "customerKey1"
        cardsController.addListener(listener1)

        XCTAssertTrue(listener1.cardsControllerDidStartLoadCardsWasCalled)
    }

    func testCardsControllerDoesntNotifyAddedListenerIfLoadingFinished() {
        let expectation = XCTestExpectation()

        mockCardsLoader.result = .success([])

        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)
        cardsController.loadCards() { _ in
            let listener1 = MockCardsControllerListener()
            cardsController.addListener(listener1)
            XCTAssertFalse(listener1.cardsControllerDidStartLoadCardsWasCalled)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testCardsControllerSetCardsToAddedListenerIfHasSavedCards() {
        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)

        let listener1 = MockCardsControllerListener()
        cardsController.addListener(listener1)

        mockCardsLoader.result = .success([.init(pan: "CardPan",
                                                 cardId: "CardId",
                                                 status: .active,
                                                 parentPaymentId: nil,
                                                 expDate: nil)])

        let expectation = XCTestExpectation()
        cardsController.loadCards() { _ in

            let listener2 = MockCardsControllerListener()
            cardsController.addListener(listener2)

            XCTAssertEqual(try! listener2.result!.get(), try! self.mockCardsLoader.result.get())

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }


    func testCardsControllerCallsAllCompletionsIfExplicitCallLoadCardsTwoTimes() {
        let cardsController = DefaultCardsController(customerKey: "customerKey1", cardsLoader: mockCardsLoader)

        mockCardsLoader.timeout = 1.0

        let firstExpectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()

        cardsController.loadCards() { result in
            firstExpectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cardsController.loadCards() { result in
                secondExpectation.fulfill()
            }
        }

        wait(for: [firstExpectation, secondExpectation], timeout: 5)
    }
}
