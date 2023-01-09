// import TinkoffReliabilityInterfaces
// import TinkoffSensitiveModeInterfaces
import UIKit

public class CellSwitchAccessoryContentView: UIView, ConfigurableView, Actionable, ContentResizingPrioritiesCustomizable {

    public typealias ActionsConfiguration = CellSwitchAccessoryContentViewActionsConfiguration

    // MARK: - Public Properties

    public private(set) var configuration: CellSwitchAccessoryContentConfiguration = .empty

    public var actionsConfiguration: ActionsConfiguration = .empty {
        didSet {
            updateActionsConfiguration()
        }
    }

    // MARK: - Overriden Properties

    override public var intrinsicContentSize: CGSize {
        layout.intrinsicContentSize ?? super.intrinsicContentSize
    }

    // MARK: - UI

    private let badgeButtonView = BadgeButtonView()
    private let switchView = UISwitch()

    private lazy var switchContainer = InsetsView<UIView>(switchView, insets: configuration.switchInsets)
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [badgeButtonView, switchContainer])
        stack.alignment = .center
        return stack
    }()

    // MARK: - Layout

    var contentResizingPriorities = ContentResizingPrioritiesConfiguration() {
        didSet {
            guard oldValue != contentResizingPriorities else { return }
            layout.invalidateLayout()
        }
    }

    @Toggle(.autoLayout.useAutoLayoutInCell)
    private var useAutoLayoutInCell

    private lazy var layoutContext = CellSwitchAccessoryLayoutContext(
        view: self,
        badgeButtonView: badgeButtonView,
        switchView: switchView
    )
    private lazy var layout: ViewLayoutProtocol = useAutoLayoutInCell.value
        ? CellSwitchAccessoryAutoLayout(
            context: layoutContext,
            contentStack: contentStack,
            switchContainerView: switchContainer
        )
        : CellSwitchAccessoryManualLayout(context: layoutContext)

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
        configuration: Configuration = .empty,
        actionsConfiguration: ActionsConfiguration = .empty
    ) {
        self.configuration = configuration
        self.actionsConfiguration = actionsConfiguration
        super.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        setupHierarchy()
        layout.setupConstraints()
        applyConfiguration(animated: false)
        updateActionsConfiguration()

        switchView.addTarget(self, action: #selector(didSwitchChangedValue(_:)), for: .valueChanged)
    }

    // MARK: - Overridden

    override public func layoutSubviews() {
        super.layoutSubviews()
        layout.layoutSubviews()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        layout.sizeThatFits(size) ?? super.sizeThatFits(size)
    }

    override public func updateConstraints() {
        layout.updateConstraints()
        super.updateConstraints()
    }
}

// MARK: - Public

public extension CellSwitchAccessoryContentView {
    func configure(with configuration: CellSwitchAccessoryContentConfiguration, animated: Bool) {
        guard self.configuration != configuration else {
            return
        }
        self.configuration = configuration
        applyConfiguration(animated: animated)
    }
}

// MARK: - Internal

extension CellSwitchAccessoryContentView {
    func sendButtonActions(for event: UIControl.Event) {
        badgeButtonView.sendButtonActions(for: event)
    }
}

// MARK: - Private

private extension CellSwitchAccessoryContentView {
    func applyConfiguration(animated: Bool) {
        applyBadgeButtonConfiguration(animated: animated)
        applySwitchConfiguration(animated: animated)

        layout.invalidateLayout()
    }

    func applyBadgeButtonConfiguration(animated: Bool) {
        badgeButtonView.configure(with: configuration.badgeButtonConfiguration, animated: animated)

        badgeButtonView.isHidden = configuration.badgeButtonConfiguration.isEmpty
    }

    func applySwitchConfiguration(animated: Bool) {
        switchView.configure(with: configuration.switchConfiguration, animated: animated)
    }

    func updateActionsConfiguration() {
        badgeButtonView.actionsConfiguration = actionsConfiguration.badgeButtonViewActionsConfiguration
    }

    func setupHierarchy() {
        if useAutoLayoutInCell.value {
            addSubview(contentStack)
        } else {
            addSubviews(badgeButtonView, switchView)
        }
    }

    @objc
    func didSwitchChangedValue(_ sender: UISwitch) {
        reconfigure(animated: false) { configuration in
            configuration.switchConfiguration.isOn = sender.isOn
        }
        actionsConfiguration.switchDidChangeValue?(sender.isOn)
    }
}

extension CellSwitchAccessoryContentView: SMSupportableObjectContainable {}
