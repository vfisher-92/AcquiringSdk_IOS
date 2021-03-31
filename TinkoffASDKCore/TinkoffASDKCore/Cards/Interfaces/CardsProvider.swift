//
//
//  CardsProvider.swift
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


import Foundation

protocol CardsProviderDataSource: AnyObject {
    func cardsProviderCards(_ cardsProvider: CardsProvider) -> [PaymentCard]
}

protocol CardsProviderDelegate: AnyObject {
    func cardsProviderNeedToLoadCards(_ cardsProvider: CardsProvider, completion: @escaping (Result<[PaymentCard], Error>) -> Void)
    func cardsProviderDeinit(_ cardsProvider: CardsProvider)
}

protocol CardsProviderListener: AnyObject {
    func cardsProvider(_ cardsProvider: CardsProvider, didUpdateState state: CardsProviderState)
}

enum CardsProviderState {
    case loading
    case data
}

protocol CardsProvider: CardsControllerListener {
    var customerKey: String { get }
    var cards: [PaymentCard] { get }
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void)
}
