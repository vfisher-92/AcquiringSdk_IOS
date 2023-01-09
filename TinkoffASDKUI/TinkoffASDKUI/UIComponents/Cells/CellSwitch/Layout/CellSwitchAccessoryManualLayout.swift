import UIKit

// TODO: MIC-6172 удалить вмесе с FT useAutoLayoutInHeader
final class CellSwitchAccessoryManualLayout {
    private let context: CellSwitchAccessoryLayoutContext

    private var layout: Layout {
        Layout(
            badgeButtonSize: context.badgeButtonView.sizeThatFits(.zero),
            switchSize: context.switchView.intrinsicContentSize, // `sizeThatFits(.zero)` return {w 51 h 31}, 2 points wider
            configuration: context.configuration
        )
    }

    init(context: CellSwitchAccessoryLayoutContext) {
        self.context = context
    }
}

extension CellSwitchAccessoryManualLayout: ViewLayoutProtocol {
    var intrinsicContentSize: CGSize? {
        layout.totalSize
    }

    func sizeThatFits(_ size: CGSize) -> CGSize? {
        layout.totalSize
    }

    func setupConstraints() {}

    func invalidateLayout() {
        context.view.invalidateIntrinsicContentSize()
        context.view.setNeedsLayout()
    }

    func updateConstraints() {}

    func layoutSubviews() {
        let layout = self.layout
        context.badgeButtonView.frame = layout.badgeButtonViewFrame
        context.switchView.frame = layout.switchFrame

        context.view.invalidateIntrinsicContentSize()
    }
}

private extension CellSwitchAccessoryManualLayout {
    struct Layout {

        // MARK: - Internal Properties

        let badgeButtonViewFrame: CGRect
        let switchFrame: CGRect
        let totalSize: CGSize

        // MARK: - Init

        init(
            badgeButtonSize: CGSize,
            switchSize: CGSize,
            configuration: CellSwitchAccessoryContentConfiguration
        ) {

            var xOffset = CGFloat.zero
            var badgeButtonViewFrame = CGRect.zero

            if configuration.badgeButtonConfiguration.isEmpty {
                badgeButtonViewFrame = .zero
            } else {
                let yBadgeOffset = configuration.minHeight / 2 - badgeButtonSize.height / 2

                badgeButtonViewFrame.origin = CGPoint(x: .zero, y: yBadgeOffset)
                badgeButtonViewFrame.size = badgeButtonSize

                xOffset = badgeButtonViewFrame.width
                    + configuration.itemSpacing
            }

            xOffset += configuration.switchInsets.left

            let ySwitchOffset = (configuration.minHeight - switchSize.height) / 2
            let origin = CGPoint(x: xOffset, y: ySwitchOffset)

            self.badgeButtonViewFrame = badgeButtonViewFrame
            switchFrame = CGRect(origin: origin, size: switchSize)

            totalSize = makeIntrinsicContentSize(
                badgeButtonSize: badgeButtonSize,
                switchSize: switchSize,
                configuration: configuration
            )
        }
    }
}

// MARK: - Calculation

private func makeIntrinsicContentSize(
    badgeButtonSize: CGSize,
    switchSize: CGSize,
    configuration: CellSwitchAccessoryContentConfiguration
) -> CGSize {
    let itemSpacing = configuration.badgeButtonConfiguration.isEmpty ? .zero : configuration.itemSpacing

    let width = makeBadgeButtonContentWidth(
        badgeButtonSize: badgeButtonSize,
        configuration: configuration
    )
        + itemSpacing
        + makeSwitchIntrinsicContentWidth(
            switchSize: switchSize,
            configuration: configuration
        )

    return CGSize(
        width: width,
        height: configuration.minHeight
    )
}

private func makeBadgeButtonContentWidth(
    badgeButtonSize: CGSize,
    configuration: CellSwitchAccessoryContentConfiguration
) -> CGFloat {
    guard !configuration.badgeButtonConfiguration.isEmpty else {
        return .zero
    }

    return badgeButtonSize.width
}

private func makeSwitchIntrinsicContentWidth(
    switchSize: CGSize,
    configuration: CellSwitchAccessoryContentConfiguration
) -> CGFloat {
    configuration.switchInsets.horizontal + switchSize.width
}
