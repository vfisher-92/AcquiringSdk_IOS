import UIKit

public struct CellContentConfiguration: Equatable {

    @frozen public enum DefaultValues {
        public static let textSpacing: CGFloat = 4.0
        public static let avatarPadding: CGFloat = 16.0
    }

    // MARK: - Public Properties

    public var avatarConfiguration: AvatarConfiguration?
    public var avatarBadgesConfiguration: BadgedContentContainerConfiguration
    public var captionConfiguration: LabelConfiguration?
    public var titleConfiguration: TextBlockConfiguration
    public var descriptionConfiguration: TextBlockConfiguration?
    public var textSpacing: CGFloat
    public var avatarPadding: CGFloat
    public var minHeight: CGFloat?

    /// SensitiveMode overlay configuration. Visible only if ``MosaicOverlayConfiguration.baseColor`` not nil and alpha is 1
    public var captionMosaicOverlayConfiguration: MosaicOverlayConfiguration

    // MARK: - Init

    public init(
        avatarConfiguration: AvatarConfiguration? = nil,
        avatarBadgesConfiguration: BadgedContentContainerConfiguration = .default(),
        captionConfiguration: LabelConfiguration? = nil,
        titleConfiguration: TextBlockConfiguration = .empty,
        descriptionConfiguration: TextBlockConfiguration? = nil,
        textSpacing: CGFloat = DefaultValues.textSpacing,
        avatarPadding: CGFloat = DefaultValues.avatarPadding,
        minHeight: CGFloat? = nil,
        captionMosaicOverlayConfiguration: MosaicOverlayConfiguration = .clear
    ) {
        self.captionConfiguration = captionConfiguration
        self.avatarConfiguration = avatarConfiguration
        self.avatarBadgesConfiguration = avatarBadgesConfiguration
        self.titleConfiguration = titleConfiguration
        self.descriptionConfiguration = descriptionConfiguration
        self.textSpacing = textSpacing
        self.avatarPadding = avatarPadding
        self.minHeight = minHeight
        self.captionMosaicOverlayConfiguration = captionMosaicOverlayConfiguration
    }

    public static let empty = CellContentConfiguration()
}

extension CellContentConfiguration {
    var hasAvatar: Bool {
        avatarConfiguration != nil
    }

    var hasCaption: Bool {
        guard let captionConfiguration = captionConfiguration else {
            return false
        }

        return !captionConfiguration.isEmpty
    }

    var hasDescription: Bool {
        guard let descriptionConfiguration = descriptionConfiguration else {
            return false
        }

        return !descriptionConfiguration.leadingConfiguration.isEmpty ||
            !descriptionConfiguration.trailingConfiguration.isEmpty
    }
}
