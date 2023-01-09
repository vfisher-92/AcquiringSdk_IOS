// import TinkoffCoreFoundation
import UIKit

final class CellSwitchAccessoryAutoLayout {
    private let context: CellSwitchAccessoryLayoutContext

    private let contentStack: UIStackView
    private let switchContainerView: InsetsView<UIView>

    private var minHeightConstraint: NSLayoutConstraint?
    private var verticalHuggingHeightConstraints: [NSLayoutConstraint] = []

    init(
        context: CellSwitchAccessoryLayoutContext,
        contentStack: UIStackView,
        switchContainerView: InsetsView<UIView>
    ) {
        self.context = context
        self.contentStack = contentStack
        self.switchContainerView = switchContainerView
    }
}

extension CellSwitchAccessoryAutoLayout: ViewLayoutProtocol {
    var intrinsicContentSize: CGSize? {
        nil
    }

    func sizeThatFits(_ size: CGSize) -> CGSize? {
        // TODO: MIC-6156 поменять на nil вмесе с удалением FT useAutoLayoutInCell
        context.view.systemLayoutSizeFitting(size)
    }

    func setupConstraints() {
        contentStack.pinEdgesToSuperview()
        minHeightConstraint = context.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)

        verticalHuggingHeightConstraints = [
            context.badgeButtonView.heightAnchor.constraint(equalTo: context.view.heightAnchor),
            switchContainerView.heightAnchor.constraint(equalTo: context.view.heightAnchor),
        ]
        NSLayoutConstraint.activate(verticalHuggingHeightConstraints)
    }

    func invalidateLayout() {
        context.view.setNeedsUpdateConstraints()
    }

    func updateConstraints() {
        contentStack.spacing = context.configuration.itemSpacing
        switchContainerView.insets = context.configuration.switchInsets

        minHeightConstraint?.isActive = context.configuration.minHeight > 0
        minHeightConstraint?.constant = context.configuration.minHeight

        updatePriorities()
    }

    func layoutSubviews() {}
}

extension CellSwitchAccessoryAutoLayout {
    func updatePriorities() {
        var contentPriorities = context.contentResizingPriorities
        contentPriorities.verticalHugging = .required
        context.badgeButtonView.contentResizingPriorities = contentPriorities
        context.switchView.apply(contentResizingPriorities: contentPriorities)

        let verticalHugging = min(
            context.contentResizingPriorities.verticalHugging,
            .almostRequired
        )
        verticalHuggingHeightConstraints.forEach { $0.priority = verticalHugging }
    }
}
