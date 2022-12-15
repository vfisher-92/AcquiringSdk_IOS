//
//  PaymentActivityView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import UIKit

enum PaymentActivityViewState {
    case loading
    case succeeded
    case failed
}

final class PaymentActivityView: UIView {
    // MARK: State

    var state: PaymentActivityViewState = .loading

    // MARK: UI

    private lazy var loadingView = PaymentActivityLoadingView(
        configuration: PaymentActivityLoadingView.Configuration(
            title: "Обрабатываем платеж",
            description: "Это займет некоторое время&Это займет некоторое время&Это займет некоторое время&Это займет некоторое время&"
        )
    )

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .topInset),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.bottomInset).with(priority: .fittingSizeLevel),
        ])
    }
}

extension PaymentActivityView {
    var estimatedHeight: CGFloat {
        systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

private extension CGFloat {
    static let topInset: CGFloat = 24
    static let horizontalInset: CGFloat = 23.5
    static let bottomInset: CGFloat = 24
}

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
