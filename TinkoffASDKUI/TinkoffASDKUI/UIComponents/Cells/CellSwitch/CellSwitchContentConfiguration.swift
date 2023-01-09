import UIKit

public struct CellSwitchContentConfiguration: Equatable, DefaultInitializable, AccessibilityElementConfigurable {

    // MARK: - Public Properties

    public var contentConfiguration: CellContentConfiguration
    public var accessoryContentConfiguration: CellSwitchAccessoryContentConfiguration
    public var spacing: CGFloat
    public var contentInsets: UIEdgeInsets
    public var accessibilityElementConfigurationResolver: AnyAccessibilityElementConfigurationResolver<Self>?
    public var accessibilityCustomButtonActionElementConfiguration: AccessibilityElementConfiguration?

    // MARK: - Init

    public init(
        contentConfiguration: CellContentConfiguration = .empty,
        accessoryContentConfiguration: CellSwitchAccessoryContentConfiguration = .empty,
        spacing: CGFloat,
        contentInsets: UIEdgeInsets,
        accessibilityElementConfigurationResolver: AnyAccessibilityElementConfigurationResolver<Self>? = .dynamic,
        accessibilityCustomButtonActionElementConfiguration: AccessibilityElementConfiguration? = nil
    ) {

        self.contentConfiguration = contentConfiguration
        self.accessoryContentConfiguration = accessoryContentConfiguration
        self.spacing = spacing
        self.contentInsets = contentInsets
        self.accessibilityElementConfigurationResolver = accessibilityElementConfigurationResolver
        self.accessibilityCustomButtonActionElementConfiguration = accessibilityCustomButtonActionElementConfiguration
    }

    public init() {
        self.init(spacing: .zero, contentInsets: .zero)
    }

    public static let empty = CellSwitchContentConfiguration()
}
