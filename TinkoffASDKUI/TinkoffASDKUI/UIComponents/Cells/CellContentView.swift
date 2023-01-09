import UIKit

public final class CellContentView: UIView, FittingSizable, ConfigurableView, ContentResizingPrioritiesCustomizable {

    // MARK: - Public Properties

    public private(set) var configuration: CellContentConfiguration = .empty

    // MARK: - Internal Properties

    var fittingSize: CGSize? {
        didSet {
            layout.invalidateLayout()
        }
    }

    // MARK: - UI

    private let badgedAvatarContainerView = BadgedContentContainerView()
    private let avatarView = AvatarView()
    private let captionTextBlockView = TextBlock()
    private let titleTextBlockView = TextBlock()
    private let descriptionTextBlockView = TextBlock()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            captionTextBlockView,
            titleTextBlockView,
            descriptionTextBlockView,
        ])
        stack.axis = .vertical
        return stack
    }()

    // MARK: - Private Properties

    var contentResizingPriorities = ContentResizingPrioritiesConfiguration() {
        didSet {
            guard oldValue != contentResizingPriorities else { return }
            layout.invalidateLayout()
        }
    }

    private var useAutoLayoutInCell = true

    private lazy var context = CellContentViewLayoutContext(
        view: self,
        badgedAvatarContainerView: badgedAvatarContainerView,
        avatarView: avatarView,
        captionView: captionTextBlockView,
        titleView: titleTextBlockView,
        descriptionView: descriptionTextBlockView
    )

    private lazy var layout: ViewLayoutProtocol = useAutoLayoutInCell.value
        ? CellContentViewAutoLayout(context: context, textStack: textStack)
        : CellContentViewManualLayout(context: context)

    // MARK: - Overriden Properties

    override public var intrinsicContentSize: CGSize {
        layout.intrinsicContentSize ?? super.intrinsicContentSize
    }

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public init(configuration: Configuration = .empty) {
        self.configuration = configuration
        super.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        setupHierarchy()
        layout.setupConstraints()
        applyConfiguration(animated: false)
    }

    // MARK: - Overriden

    override public func layoutSubviews() {
        super.layoutSubviews()

        layout.layoutSubviews()
    }

    override public func updateConstraints() {
        layout.updateConstraints()
        super.updateConstraints()
    }
}

// MARK: - Public Methods

public extension CellContentView {
    func configure(with configuration: CellContentConfiguration, animated: Bool) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        applyConfiguration(animated: animated)
    }
}

// MARK: - Setup

private extension CellContentView {
    func applyConfiguration(animated: Bool) {
        applyCaptionConfiguration(animated: animated)
        applyAvatarConfiguration(animated: animated)
        applyTitleConfiguration(animated: animated)
        applySubtitleConfiguration(animated: animated)

        layout.invalidateLayout()
    }

    func setupHierarchy() {
        if useAutoLayoutInCell {
            setupHierarchyForAutoLayout()
        } else {
            setupHierarchyForManualLayout()
        }
    }

    func setupHierarchyForAutoLayout() {
        addSubviews(textStack, badgedAvatarContainerView)
        badgedAvatarContainerView.setContent(avatarView, animated: false)
    }

    func setupHierarchyForManualLayout() {
        addSubviews(
            badgedAvatarContainerView,
            captionTextBlockView,
            titleTextBlockView,
            descriptionTextBlockView
        )

        badgedAvatarContainerView.setContent(avatarView, animated: false)
    }

    func applyCaptionConfiguration(animated: Bool) {
        if let configuration = configuration.captionConfiguration {
            captionTextBlockView.configure(
                with: TextBlockConfiguration(
                    leadingConfiguration: configuration,
                    trailingConfiguration: .empty,
                    leadingMosaicOverlayConfiguration: self.configuration.captionMosaicOverlayConfiguration
                ),
                animated: animated
            )
        }

        captionTextBlockView.isHidden = !configuration.hasCaption
    }

    func applyAvatarConfiguration(animated: Bool) {
        if let configuration = configuration.avatarConfiguration {
            avatarView.configure(with: configuration, animated: animated)
            applyAvatarBadgesConfiguration(animated: animated)
        }

        avatarView.isHidden = !configuration.hasAvatar
        badgedAvatarContainerView.isHidden = !configuration.hasAvatar
    }

    func applyAvatarBadgesConfiguration(animated: Bool) {
        badgedAvatarContainerView.configure(with: configuration.avatarBadgesConfiguration, animated: animated)
    }

    func applyTitleConfiguration(animated: Bool) {
        titleTextBlockView.configure(with: configuration.titleConfiguration, animated: animated)
    }

    func applySubtitleConfiguration(animated: Bool) {
        if let configuration = configuration.descriptionConfiguration {
            descriptionTextBlockView.configure(with: configuration, animated: animated)
        }
        descriptionTextBlockView.isHidden = !configuration.hasDescription
    }
}
