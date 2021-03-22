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
        mockCardsLoader.result = nil
        mockCardsLoader.timeout = 1.5
    }
    
    func testCardsControllerNotifyListenersWithTargetCustomerKeyWhenStartLoad() {
        let cardsController = DefaultCardsController(cardsLoader: mockCardsLoader)
        
        let listener1 = MockCardsControllerListener()
        listener1.customerKey = "customerKey1"
        cardsController.addListener(listener1)
        
        let listener2 = MockCardsControllerListener()
        listener2.customerKey = "customerKey1"
        cardsController.addListener(listener2)
        
        cardsController.loadCards(customerKey: "customerKey1") { _ in }
        
        XCTAssertTrue(listener1.cardsControllerDidStartLoadCardsWasCalled)
        XCTAssertTrue(listener2.cardsControllerDidStartLoadCardsWasCalled)
    }
    
    func testCardsControllerDoesntNotifyListenersWithNotTargetCustomerKeyWhenStartLoad() {
        let cardsController = DefaultCardsController(cardsLoader: mockCardsLoader)
        
        let listener1 = MockCardsControllerListener()
        listener1.customerKey = "customerKey1"
        cardsController.addListener(listener1)
        
        let listener2 = MockCardsControllerListener()
        listener2.customerKey = "customerKey2"
        cardsController.addListener(listener2)
        
        cardsController.loadCards(customerKey: "customerKey3") { _ in }
        
        XCTAssertFalse(listener1.cardsControllerDidStartLoadCardsWasCalled)
        XCTAssertFalse(listener2.cardsControllerDidStartLoadCardsWasCalled)
    }
    
    func testCardsControllerCallCardsLoaderOneTimeIfCalledLoadCardsTwoTimesInRowWithSameCustomerKey() {
        let cardsController = DefaultCardsController(cardsLoader: mockCardsLoader)

        cardsController.loadCards(customerKey: "customerKey1") { _ in }
        cardsController.loadCards(customerKey: "customerKey1") { _ in }
        
        XCTAssertEqual(mockCardsLoader.loadCardsTimesCalled, 1)
    }
    
    func testCardsControllerCallCardsLoaderTwoTimesIfCalledLoadCardsTwoTimesInRowWithDifferentCustomerKeys() {
        let cardsController = DefaultCardsController(cardsLoader: mockCardsLoader)

        cardsController.loadCards(customerKey: "customerKey1") { _ in }
        cardsController.loadCards(customerKey: "customerKey2") { _ in }
        
        XCTAssertEqual(mockCardsLoader.loadCardsTimesCalled, 2)
    }
}
