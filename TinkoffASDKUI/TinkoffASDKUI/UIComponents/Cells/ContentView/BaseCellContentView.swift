import UIKit

public class BaseCellContentView: UIView, FittingSizable {

    // MARK: - UI

    public var contentView: UIView {
        assertionFailure("You need to override the parameter in the subclass")
        return UIView()
    }

    public var accessoryContentView: UIView {
        assertionFailure("You need to override the parameter in the subclass")
        return UIView()
    }

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [contentView, accessoryContentView])
        stack.alignment = .top
        return stack
    }()

    // MARK: - Public Properties

    public var contentInsets: UIEdgeInsets {
        .zero
    }

    public var spacing: CGFloat {
        .zero
    }

    // MARK: - FittingSizable

    var fittingSize: CGSize? {
        set {
            layout.setFittingSize(newValue)
        }
        get {
            guard let contentView = contentView as? FittingSizable else {
                return nil
            }

            return contentView.fittingSize
        }
    }

    var useAutoLayoutInCell = true

    private lazy var layoutContext = BaseCellContentViewLayoutContext(
        view: self,
        contentView: contentView,
        accessoryContentView: accessoryContentView
    )
    private lazy var layout: BaseCellContentViewLayoutProtocol = useAutoLayoutInCell.value
        ? BaseCellContentViewAutoLayout(context: layoutContext, contentStack: contentStack)
        : BaseCellContentViewManualLayout(context: layoutContext)

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupHierarchy()
        layout.setupConstraints()
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

// MARK: - Setup

private extension BaseCellContentView {
    func setupHierarchy() {
        if useAutoLayoutInCell.value {
            addSubview(contentStack)
        } else {
            addSubviews(contentView, accessoryContentView)
        }
    }
}

extension BaseCellContentView: SMSupportableObjectContainable {}
