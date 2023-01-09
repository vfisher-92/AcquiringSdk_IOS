import Foundation

public struct CellSwitchAccessoryContentViewActionsConfiguration {

    // MARK: - Public Properties

    public var badgeButtonViewActionsConfiguration: BadgeButtonViewActionsConfiguration

    public var switchDidChangeValue: ((Bool) -> Void)?

    // MARK: - Init

    public init(
        badgeButtonViewActionsConfiguration: BadgeButtonViewActionsConfiguration = .empty,
        switchDidChangeValue: ((Bool) -> Void)? = nil
    ) {
        self.badgeButtonViewActionsConfiguration = badgeButtonViewActionsConfiguration
        self.switchDidChangeValue = switchDidChangeValue
    }

    // MARK: - Static

    public static let empty = CellSwitchAccessoryContentViewActionsConfiguration()
}
