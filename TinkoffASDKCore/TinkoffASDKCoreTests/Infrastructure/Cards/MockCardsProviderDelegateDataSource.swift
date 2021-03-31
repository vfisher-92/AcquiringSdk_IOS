//
//
//  MockCardsProviderDelegateDataSource.swift
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

final class MockCardsProviderDelegateDataSource: CardsProviderDataSource, CardsProviderDelegate {
    
    var cards = [PaymentCard]()
    var cardsProviderNeedToLoadCardsCalled = false
    var cardsProviderDeinitCalled = false
    var cardsProviderCardsCalled = false
    
    func cardsProviderCards(_ cardsProvider: CardsProvider) -> [PaymentCard] {
        cardsProviderCardsCalled = true
        return cards
    }
    
    func cardsProviderNeedToLoadCards(_ cardsProvider: CardsProvider,
                                      completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        cardsProviderNeedToLoadCardsCalled = true
    }
    
    func cardsProviderDeinit(_ cardsProvider: CardsProvider) {
        cardsProviderDeinitCalled = true
    }
}
