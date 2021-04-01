//
//
//  CardsAssembly.swift
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

final class CardsAssembly {
    
    private var cardsControllers = [String: DefaultCardsController]()
    private lazy var cardsLoader: CardsLoader = {
        DefaultCardsLoader(api: api)
    }()
    
    private let api: API
    
    init(api: API) {
        self.api = api
    }
    
    func buildCardsProvider(customerKey: String,
                            predicates: [CardsProviderPredicate],
                            synchronized: Bool,
                            listener: CardsProviderListener?) -> CardsProvider {
        if synchronized {
            return buildSynchronizedCardsProvider(customerKey: customerKey,
                                                  predicates: predicates,
                                                  listener: listener)
        } else {
            return buildNotSynchronizedCardsProvider(customerKey: customerKey,
                                                     predicates: predicates,
                                                     listener: listener)
        }
    }
}

private extension CardsAssembly {

    func buildSynchronizedCardsProvider(customerKey: String,
                                        predicates: [CardsProviderPredicate] = [],
                                        listener: CardsProviderListener?) -> CardsProvider {
        let controller = cardsControllers[customerKey] ?? DefaultCardsController(customerKey: customerKey, cardsLoader: cardsLoader)
        cardsControllers[customerKey] = controller
        
        let provider = DefaultCardsProvider(customerKey: customerKey, cardsController: controller, predicates: predicates)
        provider.listener = listener
        controller.addListener(provider)
        
        return provider
    }
    
    func buildNotSynchronizedCardsProvider(customerKey: String,
                                           predicates: [CardsProviderPredicate] = [],
                                           listener: CardsProviderListener?) -> CardsProvider {
        let controller = DefaultCardsController(customerKey: customerKey, cardsLoader: cardsLoader)
        
        let provider = DefaultCardsProvider(customerKey: customerKey, cardsController: controller, predicates: predicates)
        provider.listener = listener
        controller.addListener(provider)
                            
        return provider
    }
}
