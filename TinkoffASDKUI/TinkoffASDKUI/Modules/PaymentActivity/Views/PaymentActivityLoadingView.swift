//
//  PaymentActivityLoadingView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import Foundation

final class PaymentActivityLoadingView: UIView {
    // MARK: Configuration

    struct Configuration {
        let title: String
        let description: String
    }

    // MARK: UI

    private lazy var activityIndicator = ActivityIndicatorView(style: .paymentActivity)

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

    convenience init(configuration: Configuration) {
        self.init(frame: .zero)
        update(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func update(configuration: Configuration) {
        titleLabel.text = configuration.title
        descriptionLabel.text = configuration.description
    }

    // MARK: Initial Configuration

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center

        stack.setCustomSpacing(.indicatorBottomInset, after: activityIndicator)
        stack.setCustomSpacing(.titleBottomInset, after: titleLabel)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .stackHorizontalInset),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.stackHorizontalInset),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let indicatorBottomInset: CGFloat = 20
    static let titleBottomInset: CGFloat = 8
    static let stackHorizontalInset: CGFloat = 23.5
}

// MARK: - ActivityIndicatorView + Style

extension ActivityIndicatorView.Style {
    static var paymentActivity: ActivityIndicatorView.Style {
        ActivityIndicatorView.Style(
            lineColor: ASDKColors.yellow,
            diameter: 72,
            width: 4
        )
    }
}
