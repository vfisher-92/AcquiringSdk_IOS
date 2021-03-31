//
//
//  DefaultCardsProvider.swift
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

final class DefaultCardsProvider: CardsProvider {
    let customerKey: String
    var cards: [PaymentCard] {
        cardsController.cards
    }
    private let cardsController: CardsController
    
    weak var listener: CardsProviderListener?

    init(customerKey: String,
         cardsController: CardsController) {
        self.customerKey = customerKey
        self.cardsController = cardsController
    }
    
    deinit {
        cardsController.willDeinitListener(self)
    }
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        cardsController.loadCards(completion: completion)
    }
}

// MARK: - CardsControllerListener

extension DefaultCardsProvider: CardsControllerListener {
    func cardsControllerDidStartLoadCards(_ cardsController: CardsController) {
        listener?.cardsProvider(self, didUpdateState: .loading)
    }
    
    func cardsControllerDidStopLoadCards(_ cardsController: CardsController) {
        listener?.cardsProvider(self, didUpdateState: .data)
    }
}
