//
//  AddCardListFlow.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.12.2022.
//

import TinkoffASDKCore
import UIKit

protocol IAddCardFlow {
    func start(context: AddCardListFlowContext)
}

public struct AddCardListFlowContext {
    let presentingViewController: UIViewController
    let customerKey: String
    let output: IAddNewCardOutput?
}

final class AddCardListFlow {

    // Dependencies
    private let assembly: IAddNewCardAssembly
    private let networking: IAddNewCardNetworking

    init(assembly: IAddNewCardAssembly, networking: IAddNewCardNetworking) {
        self.assembly = assembly
        self.networking = networking
    }
}

extension AddCardListFlow: IAddCardFlow {

    func start(context: AddCardListFlowContext) {
        let addCardViewController = assembly.assemble(addNewCardOutput: context.output, networking: networking)
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        // Fixes flickering of nav bar when using pushing transitioning animation
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.backgroundColor = ASDKColors.Background.elevation1.color
        addCardViewController.extendedLayoutIncludesOpaqueBars = true
        context.presentingViewController.present(navigationController, animated: true)
    }
}
