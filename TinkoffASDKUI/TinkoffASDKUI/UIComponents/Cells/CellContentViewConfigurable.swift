import UIKit

public protocol CellContentViewConfigurable: UIView, Actionable {
    associatedtype Configuration: DefaultInitializable, Equatable
    associatedtype ActionsConfiguration

    // MARK: - Properties

    var configuration: Configuration { get }
    var actionsConfiguration: ActionsConfiguration { get set }

    func configure(with configuration: Configuration, animated: Bool)

    // MARK: - Init

    init(configuration: Configuration, actionsConfiguration: ActionsConfiguration)
}
