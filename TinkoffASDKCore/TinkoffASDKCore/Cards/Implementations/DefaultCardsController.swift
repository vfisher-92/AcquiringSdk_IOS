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
    
    private let cardsLoader: CardsLoader
    
    private var listeners = [WeakCardsControllerListener]()
    private var state = [String: Bool]()
    private var completions = [String: [(Result<[PaymentCard], Error>) -> Void]]()
    private var cards = [String: [PaymentCard]]()
    
    init(cardsLoader: CardsLoader) {
        self.cardsLoader = cardsLoader
    }
    
    func loadCards(customerKey: String,
                   completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        var customerKeyCompletions = completions[customerKey] ?? [(Result<[PaymentCard], Error>) -> Void]()
        customerKeyCompletions.append(completion)
        completions[customerKey] = customerKeyCompletions
        
        notifyListenersAboutLoadingStart(with: customerKey)
        
        let customerKeyState = state[customerKey] ?? false
        guard !customerKeyState else { return }
        
        state[customerKey] = true
        
        cardsLoader.loadCards(customerKey: customerKey) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case let .success(cards) = result {
                    self.cards[customerKey] = cards
                }
                self.state[customerKey] = false
                self.callAndResetCompletions(with: customerKey, result: result)
                self.notifyListenersAboutLoadingFinish(with: customerKey, result: result)
            }
        }
    }
    
    func removeListener(_ listener: CardsControllerListener) {
        let customerKeyListeners = listeners
            .filter { $0.value?.customerKey == listener.customerKey && $0.value !== listener }
        if customerKeyListeners.isEmpty {
            cards[listener.customerKey] = nil
        }
        
        self.listeners = self.listeners.filter { $0.value !== listener }
    }
    
    func addListener(_ listener: CardsControllerListener) {
        var listeners = self.listeners.filter { $0.value != nil }
        listeners.append(.init(value: listener))
        self.listeners = listeners
        
        let state = self.state[listener.customerKey] ?? false
        if state {
            listener.cardsControllerDidStartLoadCards(self)
        } else if let savedCards = cards[listener.customerKey] {
            listener.cardsControllerDidStopLoadCards(self, result: .success(savedCards))
        }
    }
}

private extension DefaultCardsController {
    func notifyListenersAboutLoadingStart(with customerKey: String) {
        let listeners = self.listeners.filter { $0.value?.customerKey == customerKey }
        listeners.forEach { $0.value?.cardsControllerDidStartLoadCards(self) }
    }
    
    func notifyListenersAboutLoadingFinish(with customerKey: String, result: Result<[PaymentCard], Error>) {
        let listeners = self.listeners.filter { $0.value?.customerKey == customerKey }
        listeners.forEach { $0.value?.cardsControllerDidStopLoadCards(self, result: result) }
    }
    
    func callAndResetCompletions(with customerKey: String, result: Result<[PaymentCard], Error>) {
        completions[customerKey]?.forEach { $0(result) }
        completions[customerKey] = nil
    }
}

private struct WeakCardsControllerListener {
    weak var value: CardsControllerListener?
    init(value: CardsControllerListener?) {
        self.value = value
    }
}
