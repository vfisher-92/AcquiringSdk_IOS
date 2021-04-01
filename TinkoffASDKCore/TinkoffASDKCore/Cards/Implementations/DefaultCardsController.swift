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
    private var request: Cancellable?
    
    init(customerKey: String,
         cardsLoader: CardsLoader) {
        self.customerKey = customerKey
        self.cardsLoader = cardsLoader
    }
    
    deinit {
        request?.cancel()
    }
    
    func loadCards(completion: ((Result<[PaymentCard], Error>) -> Void)?) {
        if let completion = completion {
            completions.append(completion)
        }
        notifyListenersAboutLoadingStart()
        
        guard !isLoading else { return }
        isLoading = true
        
        request = cardsLoader.loadCards(customerKey: customerKey) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case let .success(cards) = result {
                    self.cards = cards
                }
                
                self.request = nil
                self.isLoading = false
                self.notifyListenersAboutLoadingFinish(result: result)
                self.callAndResetCompletions(result: result)
            }
        }
    }
    
    func willDeinitListener(_ listener: CardsControllerListener) {
        removeListener(listener)
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
            listener.cardsControllerDidLoadCards(self)
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
        switch result {
        case .success:
            listeners.forEach { $0.value?.cardsControllerDidLoadCards(self) }
        case let .failure(error):
            listeners.forEach { $0.value?.cardsControllerDidFailedLoadCards(self, error: error) }
        }
        
    }
}

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener?) {
        self.value = value
    }
}
