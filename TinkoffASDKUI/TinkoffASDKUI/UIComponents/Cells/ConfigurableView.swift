import Foundation

public protocol ConfigurableView {
    associatedtype Configuration
    var configuration: Configuration { get }
    func configure(with configuration: Configuration, animated: Bool)
}
