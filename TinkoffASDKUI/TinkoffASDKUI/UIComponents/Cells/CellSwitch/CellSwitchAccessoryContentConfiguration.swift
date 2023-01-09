import UIKit

public struct CellSwitchAccessoryContentConfiguration: Equatable {

    // MARK: - Public Properties

    public var minHeight: CGFloat {
        didSet {
            badgeButtonConfiguration.minHeight = minHeight
        }
    }

    public var switchConfiguration: SwitchConfiguration
    public var switchInsets: UIEdgeInsets

    public var buttonConfiguration: ButtonConfiguration {
        get { badgeButtonConfiguration.buttonConfiguration }
        set { badgeButtonConfiguration.buttonConfiguration = newValue }
    }

    public var badgeConfiguration: BadgeConfiguration {
        get { badgeButtonConfiguration.badgeConfiguration }
        set { badgeButtonConfiguration.badgeConfiguration = newValue }
    }

    var isButtonHidden: Bool {
        buttonConfiguration.isEmpty
    }

    var isBadgeHidden: Bool {
        badgeConfiguration.isEmpty
    }

    public var buttonInsets: UIEdgeInsets {
        get { badgeButtonConfiguration.buttonInsets }
        set { badgeButtonConfiguration.buttonInsets = newValue }
    }

    public var badgeInsets: UIEdgeInsets {
        get { badgeButtonConfiguration.badgeInsets }
        set { badgeButtonConfiguration.badgeInsets = newValue }
    }

    public var itemSpacing: CGFloat {
        didSet {
            badgeButtonConfiguration.itemSpacing = itemSpacing
        }
    }

    // MARK: - Init

    public init(
        minHeight: CGFloat = CellDefaultValues.minHeight,
        switchConfiguration: SwitchConfiguration,
        switchInsets: UIEdgeInsets = .zero,
        buttonConfiguration: ButtonConfiguration = .empty,
        buttonInsets: UIEdgeInsets = .zero,
        badgeConfiguration: BadgeConfiguration = .empty,
        badgeInsets: UIEdgeInsets = .zero,
        itemSpacing: CGFloat = .zero
    ) {
        self.minHeight = minHeight
        self.switchConfiguration = switchConfiguration
        self.switchInsets = switchInsets
        self.itemSpacing = itemSpacing
        badgeButtonConfiguration = BadgeButtonConfiguration(
            minHeight: minHeight,
            buttonConfiguration: buttonConfiguration,
            buttonInsets: buttonInsets,
            badgeConfiguration: badgeConfiguration,
            badgeInsets: badgeInsets,
            itemSpacing: itemSpacing
        )
    }

    // MARK: - Internal

    var badgeButtonConfiguration: BadgeButtonConfiguration
}

// MARK: - Static

public extension CellSwitchAccessoryContentConfiguration {
    static let empty = CellSwitchAccessoryContentConfiguration(
        switchConfiguration: .default
    )
}
