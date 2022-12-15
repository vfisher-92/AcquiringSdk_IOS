//
//  PaymentActivityView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import UIKit

protocol PaymentActivityViewDelegate: AnyObject {
    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didChangeStateFrom oldState: PaymentActivityViewState,
        to newState: PaymentActivityViewState
    )

    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didTapPrimaryButtonWithState state: PaymentActivityViewState
    )
}

final class PaymentActivityView: UIView {
    weak var delegate: PaymentActivityViewDelegate?
    private(set) var state: PaymentActivityViewState = .idle

    // MARK: Subviews

    private lazy var processingView = PaymentActivityProcessingView()
    private lazy var processedView = PaymentActivityProcessedView(delegate: self)

    // MARK: Constraints

    private lazy var processingViewConstraints: [NSLayoutConstraint] = [
        processingView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        processingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .processingHorizontalInset),
        processingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.processingHorizontalInset),
        processingView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
            .with(priority: .fittingSizeLevel),
    ]

    private lazy var processedViewConstraints: [NSLayoutConstraint] = [
        processedView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        processedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .processedHorizontalInset),
        processedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.processedHorizontalInset),
        processedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
            .with(priority: .fittingSizeLevel),
    ]

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(delegate: PaymentActivityViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(with state: PaymentActivityViewState, animated: Bool = true) {
        guard self.state != state else { return }
        let oldState = self.state
        self.state = state

        switch state {
        case .idle:
            processingView.isHidden = true
            NSLayoutConstraint.deactivate(processingViewConstraints)
            processedView.isHidden = true
            NSLayoutConstraint.deactivate(processedViewConstraints)
        case let .processing(state):
            processingView.isHidden = false
            NSLayoutConstraint.activate(processingViewConstraints)
            processingView.update(with: state)
            processedView.isHidden = true
            NSLayoutConstraint.deactivate(processedViewConstraints)
        case let .processed(state):
            processingView.isHidden = true
            NSLayoutConstraint.deactivate(processingViewConstraints)
            processedView.isHidden = false
            NSLayoutConstraint.activate(processedViewConstraints)
            processedView.update(with: state)
        }

        delegate?.paymentActivityView(self, didChangeStateFrom: oldState, to: state)
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(processingView)
        processingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(processedView)
        processedView.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - PaymentActivityLoadedViewDelegate

extension PaymentActivityView: PaymentActivityProcessedViewDelegate {
    func paymentActivityProcessedViewDidTapPrimaryButton(_ view: PaymentActivityProcessedView) {
        delegate?.paymentActivityView(self, didTapPrimaryButtonWithState: state)
    }
}

// MARK: - PaymentActivityView + Estimated Height

extension PaymentActivityView {
    var estimatedHeight: CGFloat {
        systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - Constants

private extension CGFloat {
    static let commonTopInset: CGFloat = 24
    static let commonBottomInset: CGFloat = 24
    static let processedHorizontalInset: CGFloat = 16
    static let processingHorizontalInset: CGFloat = 23.5
}
