import UIKit

final class CellSwitchAccessoryLayoutContext {
    var view: UIView {
        _view
    }

    private unowned var _view: CellSwitchAccessoryContentView

    let badgeButtonView: ContentResizingPrioritiesCustomizableView
    let switchView: UIView

    var configuration: CellSwitchAccessoryContentConfiguration {
        _view.configuration
    }

    var contentResizingPriorities: ContentResizingPrioritiesConfiguration {
        _view.contentResizingPriorities
    }

    init(
        view: CellSwitchAccessoryContentView,
        badgeButtonView: ContentResizingPrioritiesCustomizableView,
        switchView: UIView
    ) {
        _view = view
        self.badgeButtonView = badgeButtonView
        self.switchView = switchView
    }
}
