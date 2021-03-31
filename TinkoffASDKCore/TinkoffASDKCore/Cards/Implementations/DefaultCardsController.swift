//
//
//  DefaultCardsController.swift
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

final class DefaultCardsController: UpdatableCardsController {
    
    private let customerKey: String
    private let cardsLoader: CardsLoader
    
    // Listeners
    
    private var listeners = [WeakCardsControllerListener]()
    
    // State
    
    private var isLoading = false
    private var completions = [(Result<[PaymentCard], Error>) -> Void]()
    private(set) var cards = [PaymentCard]()
    
    init(customerKey: String,
         cardsLoader: CardsLoader) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
    }
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        completions.append(completion)
        notifyListenersAboutLoadingStart()
        
        guard !isLoading else { return }
        isLoading = true
        
        cardsLoader.loadCards(customerKey: customerKey) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case let .success(cards) = result {
                    self.cards = cards
                }
                
                self.isLoading = false
                self.notifyListenersAboutLoadingFinish(result: result)
                self.callAndResetCompletions(result: result)
            }
        }
    }
    
    func removeListener(_ listener: CardsControllerListener) {
        let listeners = self.listeners.filter { $0.value !== listener }
        self.listeners = listeners
    }

    func addListener(_ listener: CardsControllerListener) {
        var listeners = self.listeners.filter { $0.value != nil }
        listeners.append(.init(value: listener))
        self.listeners = listeners
        
        if isLoading {
            listener.cardsControllerDidStartLoadCards(self)
        } else if !cards.isEmpty {
            listener.cardsControllerDidStopLoadCards(self)
        }
    }
}

private extension DefaultCardsController {
    func notifyListenersAboutLoadingStart() {
        listeners.forEach { $0.value?.cardsControllerDidStartLoadCards(self) }
    }
    
    func callAndResetCompletions(result: Result<[PaymentCard], Error>) {
        completions.forEach { $0(result) }
        completions = []
    }
    
    func notifyListenersAboutLoadingFinish(result: Result<[PaymentCard], Error>) {
        listeners.forEach { $0.value?.cardsControllerDidStopLoadCards(self) }
    }
}

extension DefaultCardsController: CardsProviderDelegate {
    func cardsProviderDeinit(_ cardsProvider: CardsProvider) {
        removeListener(cardsProvider)
    }
    
    func cardsProviderNeedToLoadCards(_ cardsProvider: CardsProvider, completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        loadCards(completion: completion)
    }
}

extension DefaultCardsController: CardsProviderDataSource {
    func cardsProviderCards(_ cardsProvider: CardsProvider) -> [PaymentCard] {
        return cards
    }
}

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener?) {
        self.value = value
    }
}
