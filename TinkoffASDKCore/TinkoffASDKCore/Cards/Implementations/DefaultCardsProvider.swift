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
    private(set) var state: CardsProviderState = .data
    private(set) var cards = [PaymentCard]()
    private let cardsController: CardsController
    private let predicates: [CardsProviderPredicate]
    
    weak var listener: CardsProviderListener?

    init(customerKey: String,
         cardsController: CardsController,
         predicates: [CardsProviderPredicate] = []) {
        self.customerKey = customerKey
        self.cardsController = cardsController
        self.predicates = predicates
        refreshCards()
    }
    
    deinit {
        cardsController.willDeinitListener(self)
    }
    
    func loadCards(completion: ((Result<[PaymentCard], Error>) -> Void)?) {
        guard Thread.isMainThread else {
            assertionFailure("call CardsProvider's methods only on Main Thread")
            return
        }
        cardsController.loadCards(completion: completion)
    }
    
    func count() -> Int {
        return cards.count
    }
    
    func card(at index: Int) -> PaymentCard {
        return cards[index]
    }
}

private extension DefaultCardsProvider {
    func refreshCards() {
        let filteredCards = cardsController.cards.filter { card in
            var result = true
            for predicate in predicates {
                result = result && predicate.predicateClosure(card)
            }
            return result
        }
        self.cards = filteredCards
    }
}

// MARK: - CardsControllerListener

extension DefaultCardsProvider: CardsControllerListener {
    func cardsControllerDidStartLoadCards(_ cardsController: CardsController) {
        state = .loading
        listener?.cardsProvider(self, didUpdateState: state)
    }
    
    func cardsControllerDidLoadCards(_ cardsController: CardsController) {
        state = .data
        refreshCards()
        listener?.cardsProvider(self, didUpdateState: state)
    }
    
    func cardsControllerDidFailedLoadCards(_ cardsController: CardsController, error: Error) {
        state = .error(error)
        listener?.cardsProvider(self, didUpdateState: state)
    }
}
