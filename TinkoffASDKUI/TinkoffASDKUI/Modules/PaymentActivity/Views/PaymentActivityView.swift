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

    private lazy var loadingView = PaymentActivityLoadingView()
    private lazy var loadedView = PaymentActivityLoadedView(delegate: self)

    // MARK: Constraints

    private lazy var loadingViewConstraints: [NSLayoutConstraint] = [
        loadingView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        loadingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .loadingHorizontalInset),
        loadingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.loadingHorizontalInset),
        loadingView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
            .with(priority: .fittingSizeLevel),
    ]

    private lazy var loadedViewConstraints: [NSLayoutConstraint] = [
        loadedView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        loadedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .loadedHorizontalInset),
        loadedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.loadedHorizontalInset),
        loadedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
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
            loadingView.isHidden = true
            NSLayoutConstraint.deactivate(loadingViewConstraints)
            loadedView.isHidden = true
            NSLayoutConstraint.deactivate(loadedViewConstraints)
        case let .loading(state):
            loadingView.isHidden = false
            NSLayoutConstraint.activate(loadingViewConstraints)
            loadingView.update(with: state)
            loadedView.isHidden = true
            NSLayoutConstraint.deactivate(loadedViewConstraints)
        case let .loaded(state):
            loadingView.isHidden = true
            NSLayoutConstraint.deactivate(loadingViewConstraints)
            loadedView.isHidden = false
            NSLayoutConstraint.activate(loadedViewConstraints)
            loadedView.update(with: state)
        }

        delegate?.paymentActivityView(self, didChangeStateFrom: oldState, to: state)
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadedView)
        loadedView.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - PaymentActivityLoadedViewDelegate

extension PaymentActivityView: PaymentActivityLoadedViewDelegate {
    func paymentActivityLoadedViewDidTapPrimaryButton(_ view: PaymentActivityLoadedView) {
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
    static let loadedHorizontalInset: CGFloat = 16
    static let loadingHorizontalInset: CGFloat = 23.5
}

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
