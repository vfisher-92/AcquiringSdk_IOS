import Foundation

///
public protocol Actionable {
    ///
    associatedtype ActionsConfiguration
    ///
    var actionsConfiguration: ActionsConfiguration { get set }
}
