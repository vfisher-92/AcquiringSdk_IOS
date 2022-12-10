//
//
//  YPButtonContainerView.swift
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

import TinkoffASDKYandexPay
import UIKit

final class YPButtonContainerView: UIView {
    let button: IYandexPayButtonContainer

    init(_ button: IYandexPayButtonContainer) {
        self.button = button
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
        ])
    }
}
