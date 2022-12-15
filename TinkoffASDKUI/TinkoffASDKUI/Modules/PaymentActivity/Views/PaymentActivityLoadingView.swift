//
//  PaymentActivityLoadingView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import Foundation

final class PaymentActivityLoadingView: UIView {
    // MARK: Subviews

    private lazy var activityIndicator = ActivityIndicatorView(style: .xlYellow)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = .zero
        label.textAlignment = .center
        return label
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(with state: PaymentActivityViewState.Loading) {
        titleLabel.text = state.title
        descriptionLabel.text = state.description
    }

    // MARK: Initial Configuration

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center

        stack.setCustomSpacing(.indicatorBottomInset, after: activityIndicator)
        stack.setCustomSpacing(.titleBottomInset, after: titleLabel)

        addSubview(stack)
        stack.pinEdgesToSuperview()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let indicatorBottomInset: CGFloat = 20
    static let titleBottomInset: CGFloat = 8
    static let stackHorizontalInset: CGFloat = 23.5
}
