struct DynamicCellSwitchAccessibilityElementConfigurationResolver: AccessibilityElementConfigurationResolver {
    func resolve(using configuration: CellSwitchContentConfiguration) -> AccessibilityElementConfiguration {
        let label = [
            configuration.contentConfiguration.captionConfiguration?.string,
            configuration.contentConfiguration.titleConfiguration.leadingConfiguration.string,
            configuration.contentConfiguration.descriptionConfiguration?.leadingConfiguration.string,
            configuration.contentConfiguration.titleConfiguration.trailingConfiguration.string,
            configuration.contentConfiguration.descriptionConfiguration?.trailingConfiguration.string,
        ]

        return AccessibilityElementConfiguration(
            label: label
                .compactMap { $0 }
                .joined(separator: " "),
            value: configuration.accessoryContentConfiguration.switchConfiguration.accessibilityElementConfiguration?.strings.value,
            traits: configuration.accessoryContentConfiguration.switchConfiguration.accessibilityElementConfiguration?.traits ?? .none
        )
    }
}

// MARK: - Helpers

public extension AnyAccessibilityElementConfigurationResolver where Configuration == CellSwitchContentConfiguration {
    static let dynamic = DynamicCellSwitchAccessibilityElementConfigurationResolver().typeErased
}
