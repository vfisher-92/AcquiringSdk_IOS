//
//
//  UIAlertController+CardScannerMock.swift
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

import UIKit

extension UIAlertController {
    static func cardScannerMock(
        confirmationHandler: @escaping (_ cardNumber: String?, _ month: Int?, _ year: Int?) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "Scanner mock",
            message: "Enter card details",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Card number"
        }

        alert.addTextField { textField in
            textField.placeholder = "Month"
        }

        alert.addTextField { textField in
            textField.placeholder = "Year"
        }

        let confirmationAction = UIAlertAction(title: "confirm", style: .default) { [weak alert] _ in
            guard let textFields = alert?.textFields, textFields.count == 3 else { return }
            let cardNumber = textFields[0].text
            let month = textFields[1].text.flatMap(Int.init)
            let year = textFields[2].text.flatMap(Int.init)

            confirmationHandler(cardNumber, month, year)
        }

        alert.addAction(confirmationAction)
        return alert
    }
}
