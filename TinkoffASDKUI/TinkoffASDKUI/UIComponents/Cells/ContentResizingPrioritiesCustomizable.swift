import UIKit

protocol ContentResizingPrioritiesCustomizable: AnyObject {
    var contentResizingPriorities: ContentResizingPrioritiesConfiguration { get set }
}

typealias ContentResizingPrioritiesCustomizableView = UIView & ContentResizingPrioritiesCustomizable
