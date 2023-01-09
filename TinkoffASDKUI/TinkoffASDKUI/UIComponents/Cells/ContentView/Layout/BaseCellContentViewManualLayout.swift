import UIKit

final class BaseCellContentViewManualLayout: BaseCellContentViewLayoutProtocol {
    private let context: BaseCellContentViewLayoutContext

    // MARK: - ContentView Constraints

    private lazy var leadingContentViewConstraint = context.contentView.leadingAnchor.constraint(
        equalTo: context.view.leadingAnchor,
        constant: context.contentInsets.left
    )

    private lazy var topContentViewConstraint = context.contentView.topAnchor.constraint(
        equalTo: context.view.topAnchor,
        constant: context.contentInsets.top
    )

    private lazy var trailingContentViewToAccessoryViewConstraint = context.contentView.trailingAnchor.constraint(
        equalTo: context.accessoryContentView.leadingAnchor,
        constant: -context.spacing
    )

    private lazy var trailingContentViewToSuperviewConstraint = context.contentView.trailingAnchor.constraint(
        equalTo: context.view.trailingAnchor,
        constant: -context.contentInsets.right
    )

    private lazy var bottomContentViewConstraint = context.contentView.bottomAnchor.constraint(
        equalTo: context.view.bottomAnchor,
        constant: -context.contentInsets.bottom
    )

    // MARK: - AccessoryContentView Constraints

    private lazy var trailingAccessoryContentViewConstraint = context.accessoryContentView.trailingAnchor.constraint(
        equalTo: context.view.trailingAnchor,
        constant: -context.contentInsets.right
    )

    private lazy var topAccessoryContentViewConstraint = context.accessoryContentView.topAnchor.constraint(
        equalTo: context.view.topAnchor,
        constant: context.contentInsets.top
    )

    private lazy var bottomAccessoryContentViewConstraint = context.accessoryContentView.bottomAnchor.constraint(
        lessThanOrEqualTo: context.view.bottomAnchor,
        constant: -context.contentInsets.bottom
    )

    init(context: BaseCellContentViewLayoutContext) {
        self.context = context
    }

    var intrinsicContentSize: CGSize? {
        nil
    }

    func sizeThatFits(_ size: CGSize) -> CGSize? {
        nil
    }

    func layoutSubviews() {
        context.view.invalidateIntrinsicContentSize()
    }

    func invalidateLayout() {
        context.view.setNeedsUpdateConstraints()
    }

    func setFittingSize(_ size: CGSize?) {
        invalidateContentViewFittingSize(fittingSize: size)
    }

    func setupConstraints() {
        setupContentView()
        setupAccessoryContentView()

        bottomContentViewConstraint.priority = UILayoutPriority(999)
        bottomAccessoryContentViewConstraint.priority = UILayoutPriority(999)
    }

    func updateConstraints() {
        leadingContentViewConstraint.updateIfNeeded(withConstant: context.contentInsets.left)
        topContentViewConstraint.updateIfNeeded(withConstant: context.contentInsets.top)
        trailingContentViewToAccessoryViewConstraint.updateIfNeeded(withConstant: -context.spacing)
        trailingContentViewToSuperviewConstraint.updateIfNeeded(withConstant: -context.contentInsets.right)
        bottomContentViewConstraint.updateIfNeeded(withConstant: -context.contentInsets.bottom)
        topAccessoryContentViewConstraint.updateIfNeeded(withConstant: context.contentInsets.top)
        trailingAccessoryContentViewConstraint.updateIfNeeded(withConstant: -context.contentInsets.right)
        bottomAccessoryContentViewConstraint.updateIfNeeded(withConstant: -context.contentInsets.bottom)

        if context.accessoryContentView.isHidden {
            trailingContentViewToAccessoryViewConstraint.isActive = false
            trailingContentViewToSuperviewConstraint.isActive = true
        } else {
            trailingContentViewToAccessoryViewConstraint.isActive = true
            trailingContentViewToSuperviewConstraint.isActive = false
        }
    }
}

// MARK: - Private

private extension BaseCellContentViewManualLayout {

    func setupContentView() {
        context.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContentViewConstraint,
            trailingContentViewToAccessoryViewConstraint,
            topContentViewConstraint,
            leadingContentViewConstraint,
        ])
    }

    func setupAccessoryContentView() {
        context.accessoryContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingAccessoryContentViewConstraint,
            topAccessoryContentViewConstraint,
            bottomAccessoryContentViewConstraint,
        ])
    }

    func invalidateContentViewFittingSize(fittingSize: CGSize?) {
        guard let contentView = context.contentView as? FittingSizable else {
            return
        }

        guard let fittingSize = fittingSize else {
            contentView.fittingSize = nil
            return
        }

        // TODO: MIC-4992 Fixed cells layout (https://jira.tcsbank.ru/browse/MIC-4992)
        var widthLimit: CGFloat = .greatestFiniteMagnitude
        if let accessoryContentView = context.accessoryContentView as? WidthLimitable {
            widthLimit = fittingSize.width * (1 - context.contentWidthPercentageThreshold) - context.contentInsets.horizontal - context.spacing
            accessoryContentView.maxWidth = widthLimit
        }

        let accessoryContentViewWidth = context.accessoryContentView.isHidden ?
            .zero :
            min(
                widthLimit,
                context.accessoryContentView.intrinsicContentSize.width
            ) + context.spacing

        let rightInset = accessoryContentViewWidth + context.contentInsets.right

        let insets = UIEdgeInsets(
            top: context.contentInsets.top,
            left: context.contentInsets.left,
            bottom: context.contentInsets.bottom,
            right: rightInset
        )

        contentView.fittingSize = fittingSize.inset(by: insets)
    }
}
