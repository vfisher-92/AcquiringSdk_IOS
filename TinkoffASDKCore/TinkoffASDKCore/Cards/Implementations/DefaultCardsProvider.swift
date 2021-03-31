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
        dataSource.cardsProviderCards(self)
    }
    private let delegate: CardsProviderDelegate
    private let dataSource: CardsProviderDataSource
    
    weak var listener: CardsProviderListener?

    init(customerKey: String,
         delegate: CardsProviderDelegate,
         dataSource: CardsProviderDataSource) {
        self.customerKey = customerKey
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    deinit {
        delegate.cardsProviderDeinit(self)
    }
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        delegate.cardsProviderNeedToLoadCards(self, completion: completion)
    }
}

// MARK: - CardsControllerListener

extension DefaultCardsProvider {
    func cardsControllerDidStartLoadCards(_ cardsController: CardsController) {
        listener?.cardsProvider(self, didUpdateState: .loading)
    }
    
    func cardsControllerDidStopLoadCards(_ cardsController: CardsController) {
        listener?.cardsProvider(self, didUpdateState: .data)
    }
}
