import UIKit

final class CellContentViewLayoutContext {
    private unowned let _view: CellContentView
    let badgedAvatarContainerView: UIView
    let avatarView: UIView
    let captionView: ContentResizingPrioritiesCustomizableView
    let titleView: ContentResizingPrioritiesCustomizableView
    let descriptionView: ContentResizingPrioritiesCustomizableView

    var view: UIView { _view }
    var configuration: CellContentConfiguration { _view.configuration }
    var fittingSize: CGSize { _view.fittingSize ?? _view.bounds.size }

    var contentResizingPriorities: ContentResizingPrioritiesConfiguration {
        _view.contentResizingPriorities
    }

    init(
        view: CellContentView,
        badgedAvatarContainerView: UIView,
        avatarView: UIView,
        captionView: ContentResizingPrioritiesCustomizableView,
        titleView: ContentResizingPrioritiesCustomizableView,
        descriptionView: ContentResizingPrioritiesCustomizableView
    ) {
        _view = view
        self.badgedAvatarContainerView = badgedAvatarContainerView
        self.avatarView = avatarView
        self.captionView = captionView
        self.titleView = titleView
        self.descriptionView = descriptionView
    }
}
