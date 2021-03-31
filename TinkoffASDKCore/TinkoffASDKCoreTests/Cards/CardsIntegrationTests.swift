//
//
//  CardsIntegrationTests.swift
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

class CardsIntegrationTests: XCTestCase {
    
    let mockCardsLoader = MockCardsLoader()
    
    let customerKey = "customerKey"
    var cardsController: DefaultCardsController {
        DefaultCardsController(customerKey: customerKey, cardsLoader: mockCardsLoader)
    }
    
    override func setUp() {
        mockCardsLoader.loadCardsTimesCalled = 0
        mockCardsLoader.result = .success([])
        mockCardsLoader.timeout = 1.5
    }

    func testProviderReturnsCorrectCardAfterLoadCardsFinished() {
        let cardsController = self.cardsController
        let cardsProvider1 = DefaultCardsProvider(customerKey: customerKey,
                                                  delegate: cardsController,
                                                  dataSource: cardsController)
        cardsController.addListener(cardsProvider1)
        
        let expectedCards: [PaymentCard] = [.init(pan: "11111",
                                                  cardId: "9999",
                                                  status: .active,
                                                  parentPaymentId: nil,
                                                  expDate: nil)]
        mockCardsLoader.result = .success(expectedCards)
        mockCardsLoader.timeout = 1.0
        
        let expectation = XCTestExpectation()
        
        cardsProvider1.loadCards { result in
            XCTAssertEqual(cardsProvider1.cards, expectedCards)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProviderReturnsCorrectCardAfterLoadCardsFinishedOnOtherProvider() {
        let cardsController = self.cardsController
        
        let cardsProvider1 = DefaultCardsProvider(customerKey: customerKey,
                                                  delegate: cardsController,
                                                  dataSource: cardsController)
        cardsController.addListener(cardsProvider1)
        
        let cardsProvider2 = DefaultCardsProvider(customerKey: customerKey,
                                                  delegate: cardsController,
                                                  dataSource: cardsController)
        cardsController.addListener(cardsProvider2)
        
        let expectedCards: [PaymentCard] = [.init(pan: "11111",
                                                  cardId: "9999",
                                                  status: .active,
                                                  parentPaymentId: nil,
                                                  expDate: nil)]
        mockCardsLoader.result = .success(expectedCards)
        mockCardsLoader.timeout = 1.0
        
        let expectation = XCTestExpectation()
        
        cardsProvider1.loadCards { result in
            XCTAssertEqual(cardsProvider2.cards, expectedCards)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProviderListenersNotifiedWithStateChangesWhenLoading() {
        let cardsController = self.cardsController
        
        let cardsProvider1 = DefaultCardsProvider(customerKey: customerKey,
                                                  delegate: cardsController,
                                                  dataSource: cardsController)
        cardsController.addListener(cardsProvider1)
        
        let cardsProvider1Listener = MockCardsProviderListener()
        cardsProvider1.listener = cardsProvider1Listener
        
        let cardsProvider2 = DefaultCardsProvider(customerKey: customerKey,
                                                  delegate: cardsController,
                                                  dataSource: cardsController)
        cardsController.addListener(cardsProvider2)
        
        let cardsProvider2Listener = MockCardsProviderListener()
        cardsProvider2.listener = cardsProvider2Listener
        
        mockCardsLoader.timeout = 1.0
        
        let expectation = XCTestExpectation()
        
        cardsProvider1.loadCards { result in
            XCTAssertEqual(cardsProvider1Listener.states, [.loading, .data])
            XCTAssertEqual(cardsProvider2Listener.states, [.loading, .data])
            expectation.fulfill()
        }
        
        XCTAssertEqual(cardsProvider1Listener.states, [.loading])
        XCTAssertEqual(cardsProvider2Listener.states, [.loading])
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCardsControllerDeinitIfAllProvidersDeinit() {
        var cardsController: DefaultCardsController? = self.cardsController
        
        var cardsProvider1: DefaultCardsProvider? = DefaultCardsProvider(customerKey: customerKey,
                                                                         delegate: cardsController!,
                                                                         dataSource: cardsController!)
        cardsController?.addListener(cardsProvider1!)
        
        var cardsProvider2: DefaultCardsProvider? = DefaultCardsProvider(customerKey: customerKey,
                                                                         delegate: cardsController!,
                                                                         dataSource: cardsController!)
        cardsController?.addListener(cardsProvider2!)
        
        weak var weakCardsController = cardsController
        cardsController = nil
        
        XCTAssertNotNil(weakCardsController)
        cardsProvider1 = nil
        cardsProvider2 = nil
        XCTAssertNil(weakCardsController)
    }
}
