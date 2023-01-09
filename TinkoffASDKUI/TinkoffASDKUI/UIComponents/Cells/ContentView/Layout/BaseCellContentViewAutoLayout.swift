import UIKit

final class BaseCellContentViewAutoLayout: BaseCellContentViewLayoutProtocol {
    private let context: BaseCellContentViewLayoutContext
    private let contentStack: UIStackView

    private var insetsConstraintsContainer: PinEdgesConstraintsContainer?
    private var accessoryMaxWidthConstraint: NSLayoutConstraint?

    init(context: BaseCellContentViewLayoutContext, contentStack: UIStackView) {
        self.context = context
        self.contentStack = contentStack
    }

    var intrinsicContentSize: CGSize? { nil }

    func sizeThatFits(_ size: CGSize) -> CGSize? { nil }

    func setupConstraints() {
        insetsConstraintsContainer = contentStack.pinEdgesToSuperview()
        accessoryMaxWidthConstraint = context.accessoryContentView.widthAnchor.constraint(
            lessThanOrEqualTo: context.view.widthAnchor,
            multiplier: 1 - context.contentWidthPercentageThreshold
        )

        NSLayoutConstraint.activate([
            context.contentView.heightAnchor
                .constraint(equalTo: contentStack.heightAnchor)
                .withPriority(.almostRequired),
            context.accessoryContentView.heightAnchor
                .constraint(equalTo: contentStack.heightAnchor)
                .withPriority(.defaultLow - 1),
            accessoryMaxWidthConstraint,
        ].compactMap { $0 })
    }

    func invalidateLayout() {
        context.view.setNeedsUpdateConstraints()
    }

    func setFittingSize(_ size: CGSize?) {}

    func updateConstraints() {
        contentStack.spacing = context.spacing
        insetsConstraintsContainer?.update(insets: context.contentInsets)
        accessoryMaxWidthConstraint?.constant = -context.contentInsets.horizontal - context.spacing

        updatePriorities()
    }

    func layoutSubviews() {}
}

extension BaseCellContentViewAutoLayout {
    func updatePriorities() {
        let contentView = context.contentView as? ContentResizingPrioritiesCustomizable
        contentView?.contentResizingPriorities = ContentResizingPrioritiesConfiguration(
            verticalHugging: .required,
            horizontalHugging: .defaultHigh,
            verticalCompressionResistance: .required,
            horizontalCompressionResistance: .required - 7
        )

        let accessoryContentView = context.accessoryContentView as? ContentResizingPrioritiesCustomizable
        accessoryContentView?.contentResizingPriorities = ContentResizingPrioritiesConfiguration(
            verticalHugging: .required,
            horizontalHugging: .required,
            verticalCompressionResistance: .required,
            horizontalCompressionResistance: .required - 6
        )
    }
}
