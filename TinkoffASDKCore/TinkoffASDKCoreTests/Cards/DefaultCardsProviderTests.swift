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
        let mockCardsProviderDelegateDataSource = MockCardsProviderDelegateDataSource()
        let provider = DefaultCardsProvider(customerKey: "",
                                            delegate: mockCardsProviderDelegateDataSource,
                                            dataSource: mockCardsProviderDelegateDataSource)
        
        provider.loadCards(completion: { _ in })
        XCTAssertTrue(mockCardsProviderDelegateDataSource.cardsProviderNeedToLoadCardsCalled)
    }
    
    func testDelegateCalledWhenProviderDeinit() {
        let mockCardsProviderDelegateDataSource = MockCardsProviderDelegateDataSource()
        var provider: DefaultCardsProvider? = DefaultCardsProvider(customerKey: "",
                                                                   delegate: mockCardsProviderDelegateDataSource,
                                                                   dataSource: mockCardsProviderDelegateDataSource)
        
        provider = nil
        XCTAssertTrue(mockCardsProviderDelegateDataSource.cardsProviderDeinitCalled)
    }
    
    func testDataSourceCalledWhenCardsRequestedFromProvider() {
        let mockCardsProviderDelegateDataSource = MockCardsProviderDelegateDataSource()
        let provider = DefaultCardsProvider(customerKey: "",
                                            delegate: mockCardsProviderDelegateDataSource,
                                            dataSource: mockCardsProviderDelegateDataSource)
        let _ = provider.cards
        XCTAssertTrue(mockCardsProviderDelegateDataSource.cardsProviderCardsCalled)
    }
    
    func testListenerGetCorrectStatesFromProvider() {
        let mockCardsProviderDelegateDataSource = MockCardsProviderDelegateDataSource()
        let provider = DefaultCardsProvider(customerKey: "",
                                            delegate: mockCardsProviderDelegateDataSource,
                                            dataSource: mockCardsProviderDelegateDataSource)
        
        let listener = MockCardsProviderListener()
        let cardsController = MockCardsController()
        
        provider.listener = listener
        
        provider.cardsControllerDidStartLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        provider.cardsControllerDidStartLoadCards(cardsController)
        provider.cardsControllerDidStopLoadCards(cardsController)
        
        XCTAssertEqual(listener.states, [.loading, .data, .data, .loading, .data])
    }
}
