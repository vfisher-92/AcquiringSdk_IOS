//
//  PaymentActivityViewState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.12.2022.
//

import Foundation

enum PaymentActivityViewState: Equatable {
    struct Loaded: Equatable {
        let image: UIImage
        let title: String
        let description: String?
        let primaryButtonTitle: String

        init(
            image: UIImage,
            title: String,
            description: String? = nil,
            primaryButtonTitle: String
        ) {
            self.image = image
            self.title = title
            self.description = description
            self.primaryButtonTitle = primaryButtonTitle
        }
    }

    struct Loading: Equatable {
        let title: String
        let description: String
    }

    case idle
    case loading(Loading)
    case loaded(Loaded)
}
