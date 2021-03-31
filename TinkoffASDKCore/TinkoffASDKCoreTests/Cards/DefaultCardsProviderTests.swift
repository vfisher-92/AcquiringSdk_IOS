//
//
//  DefaultCardsProviderTests.swift
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

class DefaultCardsProviderTests: XCTestCase {
    
    func testDelegateCalledWhenLoadCardsCalled() {
        let cardsController = MockCardsController()
        let provider = DefaultCardsProvider(customerKey: "", cardsController: cardsController)
        
        provider.loadCards(completion: { _ in })
        XCTAssertTrue(cardsController.loadCardsCalled)
    }
    
    func testDelegateCalledWhenProviderDeinit() {
        let cardsController = MockCardsController()
        var provider: DefaultCardsProvider? = DefaultCardsProvider(customerKey: "", cardsController: cardsController)

        provider = nil
        XCTAssertTrue(cardsController.willDeinitListenerCalled)
    }
    
    func testDataSourceCalledWhenCardsRequestedFromProvider() {
        let cardsController = MockCardsController()
        let provider = DefaultCardsProvider(customerKey: "",
                                            cardsController: cardsController)
        let _ = provider.cards
        XCTAssertTrue(cardsController.cardsCalled)
    }
    
    func testListenerGetCorrectStatesFromProvider() {
        let cardsController = MockCardsController()
        let provider = DefaultCardsProvider(customerKey: "",
                                            cardsController: cardsController)
        
        let listener = MockCardsProviderListener()
        
        provider.listener = listener
        
        provider.cardsControllerDidStartLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        provider.cardsControllerDidStartLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        
        XCTAssertEqual(listener.states, [.loading, .data, .data, .loading, .data])
    }
}
