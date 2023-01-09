import UIKit

final class BaseCellContentViewLayoutContext {
    private unowned let _view: BaseCellContentView
    let contentView: UIView
    let accessoryContentView: UIView

    var view: UIView { _view }

    var contentInsets: UIEdgeInsets { _view.contentInsets }
    var spacing: CGFloat { _view.spacing }

    let contentWidthPercentageThreshold: CGFloat = 0.4

    init(
        view: BaseCellContentView,
        contentView: UIView,
        accessoryContentView: UIView
    ) {
        _view = view
        self.contentView = contentView
        self.accessoryContentView = accessoryContentView
    }
}
