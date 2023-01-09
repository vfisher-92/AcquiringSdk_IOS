import UIKit.UIView

public extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview(_:))
    }

    func addSubviews(_ views: [UIView]) {
        views.forEach(addSubview(_:))
    }

    func setAnchorPoint(_ point: CGPoint) {
        let newPoint = CGPoint(
            x: bounds.size.width * point.x,
            y: bounds.size.height * point.y
        ).applying(transform)

        let oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x,
            y: bounds.size.height * layer.anchorPoint.y
        ).applying(transform)

        layer.position = CGPoint(
            x: layer.position.x - oldPoint.x + newPoint.x,
            y: layer.position.y - oldPoint.y + newPoint.y
        )
        layer.anchorPoint = point
    }
}
