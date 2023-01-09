import UIKit

public final class CellSwitchContentView: BaseCellContentView, CellContentViewConfigurable, ConfigurableView, Actionable {
    // MARK: - Public Properties

    public private(set) var configuration: CellSwitchContentConfiguration = .empty

    public var actionsConfiguration: CellSwitchContentViewActionsConfiguration = .empty {
        didSet {
            updateActionsConfiguration()
        }
    }

    // MARK: - Public UI

    override public var contentView: UIView {
        cellSwitchContentView
    }

    override public var accessoryContentView: UIView {
        cellSwitchAccessoryContentView
    }

    override public var contentInsets: UIEdgeInsets {
        configuration.contentInsets
    }

    override public var spacing: CGFloat {
        configuration.spacing
    }

    // MARK: - UI

    private let cellSwitchContentView = CellContentView()
    private let cellSwitchAccessoryContentView = CellSwitchAccessoryContentView(configuration: .empty)

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public init(
        configuration: CellSwitchContentConfiguration = .empty,
        actionsConfiguration: CellSwitchContentViewActionsConfiguration = .empty
    ) {
        self.configuration = configuration
        self.actionsConfiguration = actionsConfiguration
        super.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        applyConfiguration(animated: false)
        updateActionsConfiguration()
    }

    // MARK: - Overridden

    override public func accessibilityActivate() -> Bool {
        configuration.accessoryContentConfiguration.switchConfiguration.isOn.toggle()
        return true
    }
}

// MARK: - ViewReusable

extension CellSwitchContentView: Reusable {
    public func prepareForReuse() {
        actionsConfiguration = .empty
    }
}

// MARK: - Public Methods

public extension CellSwitchContentView {
    func configure(with configuration: CellSwitchContentConfiguration, animated: Bool) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        applyConfiguration(animated: animated)
    }
}

// MARK: - Configuration

private extension CellSwitchContentView {
    func applyConfiguration(animated: Bool) {
        applyContentConfiguration(animated: animated)
        applyAccessoryContentConfiguration(animated: animated)

        setNeedsLayout()
        setNeedsUpdateConstraints()
        invalidateIntrinsicContentSize()
    }

    func applyContentConfiguration(animated: Bool) {
        cellSwitchContentView.configure(with: configuration.contentConfiguration, animated: animated)
    }

    func updateActionsConfiguration() {
        cellSwitchAccessoryContentView.actionsConfiguration = actionsConfiguration
    }

    func applyAccessoryContentConfiguration(animated: Bool) {
        cellSwitchAccessoryContentView.configure(
            with: configuration.accessoryContentConfiguration,
            animated: animated
        )
    }
}
